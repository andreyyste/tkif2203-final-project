# 🎯 Panduan Jawaban Wawancara (Interview Preparation Cheatsheet)
## Final Project: Database Technology — VOD Streaming Service

Dokumen ini berisi jawaban lengkap untuk **seluruh 17 pertanyaan wawancara** resmi dari dosen. Pelajari dokumen ini agar Anda bisa menjawab dengan lancar dan percaya diri saat sesi interview.

---

## 1. Design & Mapping

### Q1: Which Sakila tables did you keep, rename, split, or drop, and why?
- **Kept / Renamed:** 
  - `language` → `languages` (Tetap disimpan untuk melacak audio dubbing & subtitles).
  - `category` & `film_category` → `genres` & `content_genres` (Diubah namanya agar sesuai terminologi industri streaming).
  - `actor` & `film_actor` → `cast_members` & `content_cast` (Diperluas untuk menyimpan peran sutradara/pemeran).
- **Split:**
  - `film` → Dipecah menjadi `contents` (metadata utama), `movies` (film lepas), dan `series` + `episodes` (serial TV bertingkat). Alasan: Sakila hanya mendukung film lepas 1 kaset, sedangkan VOD modern memiliki serial ber-episode.
  - `customer` → Dipecah menjadi `users` (akun pembayaran) dan `user_profiles` (profil penonton di bawah akun). Alasan: 1 akun Netflix/Disney+ digunakan oleh banyak profil pengguna.
- **Dropped / Replaced:**
  - `inventory`, `store`, `staff` → Dihapus. Alasan: Bisnis streaming bersifat serba digital, tidak memerlukan stok kaset fisik, toko fisik, maupun staf kasir. Digantikan oleh `content_providers` & `content_licenses`.
  - `rental` & `payment` → Dihapus & digantikan oleh `streaming_sessions` (log pemutaran digital) serta `subscriptions` & `payment_transactions` (model langganan bulanan).

### Q2: Walk me through how a rental row in Sakila maps to your streaming_session design.
- Di Sakila, 1 baris `rental` mencatat: `rental_id`, `rental_date`, `inventory_id` (kaset fisik mana), `customer_id` (siapa penyewa), `return_date`, dan `staff_id`.
- Di database Streaming saya, ini ditransformasi menjadi 1 baris `streaming_sessions`:
  - `rental_id` → `session_id` (BIGSERIAL).
  - `customer_id` → `profile_id` (menunjukkan profil spesifik mana yang menonton).
  - `inventory_id` → `content_id` dan `episode_id` (menunjukkan konten digital yang diputar).
  - `rental_date` & `return_date` → `start_time` & `end_time` (beserta perhitungan `watch_duration_seconds`).
  - Tambahan telemetri VOD: `device_id` (perangkat apa), `max_bitrate_kbps` (kualitas video), `is_completed` (apakah tuntas ditonton), dan `user_ip`.

### Q3: What was the trickiest modeling decision you made, and what alternatives did you consider?
- **Keputusan Ter-sulit:** Merancang hubungan antara `contents`, `movies`, `series`, dan `episodes`.
- **Alternatif yang Dipertimbangkan:** Menyimpan semua dalam 1 tabel `contents` dengan banyak kolom NULLable (Single Table Inheritance).
- **Alasan Pilihan Akhir:** Saya memilih Class Table Inheritance (memecah menjadi `contents`, `movies`, `series`, `episodes`). Meskipun membutuhkan JOIN saat kueri, cara ini menjamin kelayakan normalisasi (3NF), menghindari ribuan nilai NULL pada kolom durasi/episode, dan mencegah *data anomaly*.

---

## 2. Schema & Constraints

### Q4: Point to a foreign key in your schema and explain what business rule it enforces.
- **Contoh FK:** `user_profiles(user_id) REFERENCES users(user_id) ON DELETE CASCADE`.
- **Aturan Bisnis:** Aturan ini memastikan bahwa setiap profil penonton **wajib dimiliki oleh 1 akun pengguna terdaftar yang valid**. Jika akun pengguna tersebut dihapus (`users` dihapus), maka seluruh profil di bawah akun tersebut secara otomatis akan ikut terhapus (*CASCADE*) untuk menjaga integritas data (tidak ada *orphan profile*).

### Q5: Where did you apply normalization, and is there a place you deliberately denormalized for analytics? Why?
- **Normalisasi (3NF):** Diterapkan pada seluruh tabel OLTP transaksi utama (`users`, `user_profiles`, `contents`, `movies`, `episodes`, `streaming_sessions`) agar tidak ada redundansi data dan mempermudah update transaksi harian.
- **Denormalisasi (Tabel Agregat OLAP):** Diterapkan pada tabel `daily_content_performance` (`stat_date`, `content_id`, `country_id`, `total_plays`, `total_watch_hours`). 
- **Alasan:** Menghitung total jam tonton dari jutaan baris `streaming_sessions` setiap kali kueri dashboard dijalankan sangat lambat. Tabel agregat denormalisasi ini mempercepat kueri analitik hingga 100x lipat.

### Q6: What would break if you removed a NOT NULL or UNIQUE constraint from a specific column of your choice?
- **Contoh 1 (Hapus `UNIQUE` di `users.email`):** Satu email yang sama bisa mendaftar berkali-kali dengan password berbeda. Sistem autentikasi/login akan *crash* atau salah mengembalikan data akun saat user mencoba *login*.
- **Contoh 2 (Hapus `NOT NULL` di `streaming_sessions.profile_id`):** Log sesi streaming bisa tercatat tanpa diketahui profil mana yang menonton. Ini merusak kalkulasi rekomendasi film, rekomendasi profil, dan analitik perilaku penonton.

---

## 3. SQL & Querying

### Q7: Run one of your analytics queries live — explain what it measures and why it's useful to the business.
- **Kueri yang Di-demo-kan:** *Top Content by Watch Duration & Region* (Kueri #2 di file `04-analytics-queries.sql`).
- **Yang Diukur:** Total akumulasi jam tonton (`total_watch_hours`) dan total pemutaran untuk setiap film/series dikelompokkan berdasarkan negara pengguna.
- **Manfaat Bisnis:** Membantu tim pengadaan lisensi (*Content Acquisition Team*) untuk mengetahui film apa yang paling disukai di wilayah tertentu (misal: Indonesia suka Horor, Jepang suka Anime), sehingga keputusan pembelian hak lisensi bernilai miliaran rupiah bisa tepat sasaran.

### Q8: How would you modify this query to filter by a specific region or date range?
- Tunjukkan penambahan klausa `WHERE`:
  ```sql
  -- Menambahkan filter negara 'Indonesia' dan rentang tanggal 7 hari terakhir
  WHERE c.country_name = 'Indonesia'
    AND s.start_time >= CURRENT_DATE - INTERVAL '7 days'
  ```

### Q9: Which of your tables would you index first for performance, and why?
- **Tabel Pertama:** Tabel `streaming_sessions`.
- **Alasan:** Tabel ini adalah tabel transaksi terbesar (*high-cardinality event log*) yang tumbuh paling cepat.
- **Index yang Dibuat:** Composite Index `(content_id, start_time)` dan Index `(profile_id, start_time DESC)`. Tanpa index ini, kueri analitik harian akan memaksa PostgreSQL melakukan *Full Table Scan* pada jutaan baris log yang sangat lambat.

---

## 4. Analytics & Features

### Q10: Which of the three+ streaming features did you implement, and how does your schema support it end-to-end?
Saya mengimplementasikan 3 fitur utama:
1. **Personalized Recommendations (Co-Watch Counts):** Didukung oleh `streaming_sessions` dan kueri *Self-Join* untuk menghitung berapa kali dua film ditonton bersamaan oleh profil yang sama.
2. **Adaptive Bitrate Tracking & QoE Metrics:** Didukung oleh kolom `max_bitrate_kbps` dan `watch_duration_seconds` di tabel `streaming_sessions` untuk menganalisis kualitas jaringan dan perangkat pengguna.
3. **Regional Licensing Windows:** Didukung oleh tabel `content_licenses` yang menghubungkan `content_id`, `country_id`, `start_date`, dan `end_date` untuk mengecek validitas hak tayang sebelum video diputar.

### Q11: How would you compute churn or retention from your schema? Walk through the tables involved.
- **Tabel yang Terlibat:** `users`, `subscription_plans`, `user_profiles`, dan `streaming_sessions`.
- **Alur Perhitungan Churn:**
  1. Ambil seluruh pengguna aktif di tabel `users` (`account_status = 'ACTIVE'`).
  2. Hubungkan ke `user_profiles` dan cari tanggal streaming terakhir di `streaming_sessions` (`MAX(start_time)`).
  3. Pengguna dikategorikan berisiko **Churn** jika `MAX(start_time)` bernilai lebih dari 14 hari yang lalu (atau tidak pernah streaming sama sekali).

### Q12: If the business wanted a new metric tomorrow (e.g., "average session length per device type"), how would your schema support that?
- Schema saya **langsung mendukungnya tanpa perlu mengubah struktur tabel (zero schema migration)**!
- Karena tabel `streaming_sessions` sudah memiliki FK `device_id` yang terhubung ke tabel `devices(device_type)`, dan mencatat `watch_duration_seconds`.
- Kueri SQL yang dijalankan:
  ```sql
  SELECT d.device_type, ROUND(AVG(s.watch_duration_seconds)/60.0, 2) AS avg_session_minutes
  FROM streaming_sessions s
  JOIN devices d ON s.device_id = d.device_id
  GROUP BY d.device_type;
  ```

---

## 5. Data & Demonstration

### Q13: Show me a row of sample data and trace it through two related tables.
- **Contoh Penelusuran (Data Trace):**
  1. Buka tabel `users`: Baris User `user_id = 1` (Email: `budi@example.com`, Plan: `Premium`).
  2. Ditelusuri ke `user_profiles`: `user_id = 1` memiliki 2 profil (`profile_id = 1`: "Budi Utama", `profile_id = 2`: "Budi Kids").
  3. Ditelusuri ke `streaming_sessions`: Profil `profile_id = 1` memiliki log streaming memutar `content_id = 3` ("Stranger Things Season 1 Episode 1") pada perangkat `device_id = 2` ("Budi's Smart TV").

### Q14: If a user deletes their account, which tables are affected, and how does your schema handle that (cascade, soft delete, etc.)?
- **Penanganan:** Menggabungkan **Soft Delete** di level Akun dan **CASCADE** pada data anak.
- **Alur:** 
  1. Saat user menghapus akun, `users.account_status` diubah menjadi `'CANCELLED'` (*Soft Delete*) agar riwayat transaksi keuangan (`payment_transactions`) tetap tersimpan untuk audit pembukuan/keuangan.
  2. Jika baris `users` benar-benar dihapus secara permanen dari basis data, klausa `ON DELETE CASCADE` pada `user_profiles`, `devices`, `watchlists`, dan `ratings` akan otomatis membersihkan seluruh data pribadi profil tersebut demi privasi pengguna (GDPR Compliance).

---

## 6. Trade-offs & Reflection

### Q15: What privacy or PII consideration did you account for in your design?
1. **Password Hashing:** Password tidak pernah disimpan mentah, melainkan menggunakan `password_hash`.
2. **Minimisasi PII:** Detail kartu kredit/pembayaran tidak disimpan di database ini (hanya menyimpan status & ID transaksi).
3. **Anonymization Log:** Alamat IP pada `streaming_sessions` di-masking/dikaji ulang secara berkala, serta mendukung *Hard Delete Cascade* pada profil saat akun dihapus untuk mematuhi regulasi UU PDP / GDPR.

### Q16: If you had one more week, what would you change or add?
1. **Table Partitioning:** Mengimplementasikan *Native Range Partitioning* pada tabel `streaming_sessions` berdasarkan bulan/tahun (`start_time`), agar manajemen data pemutaran bernilai jutaan baris lebih efisien.
2. **Feature Store / ML Pipeline Table:** Menambahkan tabel fitur khusus *Machine Learning* untuk memprediksi skor rekomendasi film secara *real-time*.

### Q17: What's one thing you'd do differently if you started this project over?
- Saya akan langsung merancang sistem **Episodic Content** (`series` & `episodes`) dari hari pertama pembuatan ERD, daripada menganggap semua konten sebagai film lepas. Pemisahan film dan serial sejak awal mempermudah penataan relasi lisensi dan sesi pemutaran.
