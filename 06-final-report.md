# 📄 Section 6: Executive Report & Design Rationale

**Course:** TKIF2203 – Database Technology  
**Instructor:** Dr. Guntur D Putra  
**Student:** Andrey (TKIF2203)  
**Project:** VOD Streaming Service Relational Database Architecture

---

## 1. Executive Summary & Design Choices
This project modernizes the legacy Sakila DVD rental database into a scalable, production-ready relational database schema tailored for a modern Video-on-Demand (VOD) Streaming Service (e.g., Netflix). 

The primary transformation replaces brick-and-mortar rental entities (`store`, `staff`, `inventory`, `rental`) with high-throughput cloud streaming infrastructure entities:
- **Account Hierarchy:** Separated account-level billing (`users`) from individual viewer personas (`user_profiles`).
- **Media Catalog Inheritance:** Split flat film records into Class Table Inheritance (`contents`, `movies`, `series`, `episodes`) to natively support both standalone films and multi-season episodic shows.
- **Digital Rights & Licensing:** Introduced `content_licenses` and `content_providers` to enforce territory-based availability windows and geoblocking.
- **Telemetry Telemetry:** Replaced manual disk return logs with high-cardinality event telemetry (`streaming_sessions`) capturing play duration, QoE bitrate, completion flags, and device metadata.

---

## 2. Normalization Trade-offs (OLTP vs OLAP Architecture)

### Transactional Engine (OLTP) — 3NF Enforcement
For day-to-day transactional operations (user registration, profile management, subscription processing, watchlist updates), the schema strictly enforces **Third Normal Form (3NF)**:
- **1NF:** Multi-valued fields (e.g., film genres or cast lists) are extracted into distinct junction tables (`content_genres`, `content_cast`).
- **2NF:** Attributes dependent on part of a composite key are separated (e.g., episode metadata is tied to `episode_id` and `series_id`, not embedded inside series records).
- **3NF:** Transitive dependencies are eliminated (e.g., country codes and names are isolated in `countries` rather than duplicated inside `users`).

### Analytics Engine (OLAP) — Deliberate Denormalization
While 3NF ensures data integrity for write-heavy OLTP workloads, aggregating metrics over millions of high-frequency `streaming_sessions` rows introduces severe JOIN bottlenecks.

To address this, we implemented an **OLAP summary table (`daily_content_performance`)**:
- Pre-aggregates daily plays, watch hours, completion counts, and unique viewers per title per region.
- Populated via an automated SQL ETL pipeline.
- Reduces dashboard reporting query latencies from multi-second full-table scans to sub-millisecond index lookups.

---

## 3. Indexing Strategy & Scalability Planning

### Indexing Strategy
To prevent performance degradation as streaming logs scale into millions of rows, targeted B-Tree composite indexes were constructed:
1. **`idx_sessions_content_time` (`streaming_sessions(content_id, start_time)`)**: Accelerates time-range aggregation queries for content performance analytics.
2. **`idx_sessions_profile_time` (`streaming_sessions(profile_id, start_time DESC)`)**: Optimizes recent watch history lookups for recommendation algorithms.
3. **`idx_users_country_plan` (`users(country_id, plan_id)`)**: Optimizes subscriber demographic and churn risk queries.
4. **`idx_licenses_geo` (`content_licenses(country_id, start_date, end_date)`)**: Ensures sub-millisecond geoblocking validation when a user initiates a stream.

### Scalability & Partitioning Roadmap
If streaming telemetry scales past 100 million rows:
- **Range Partitioning:** `streaming_sessions` will be partitioned by monthly ranges on `start_time`.
- **Cold Storage Archival:** Sessions older than 12 months will be moved to cold analytical storage (e.g., PostgreSQL table partitions detached to Parquet/S3).

---

## 4. Privacy, Legal & PII Considerations (GDPR / UU PDP Compliance)

1. **PII Minimization & Password Hashing:**
   - Passwords are strictly stored as cryptographic hashes (`password_hash` using bcrypt/argon2).
   - Raw payment card numbers are never stored in the database; only transactional status codes and provider reference IDs are retained in `payment_transactions`.

2. **Account Deletion & Data Anonymization:**
   - **Soft Delete for Users:** User account cancellation sets `account_status = 'CANCELLED'` while keeping financial records intact for tax audit compliance.
   - **Hard Delete & Cascading:** If a user requests complete GDPR erasure ("Right to be Forgotten"), `ON DELETE CASCADE` purges all personal viewer profiles (`user_profiles`), watchlists, and recommendations. Financial logs in `payment_transactions` switch `user_id` to `NULL` via `ON DELETE SET NULL`, preserving revenue totals while removing PII connection.

3. **Telemetry IP Anonymization:**
   - IP addresses recorded in `streaming_sessions` are masked after 30 days to protect user location privacy.
