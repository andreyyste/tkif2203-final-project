-- ============================================================================
-- FINAL PROJECT: VOD STREAMING SERVICE SAMPLE DATA (PostgreSQL DML)
-- Course: TKIF2203 - Database Technology
-- Instructor: Dr. Guntur D Putra
-- Student: Andrey (TKIF2203)
-- ============================================================================

-- 1. COUNTRIES DATA
INSERT INTO countries (country_id, country_code, country_name) VALUES
(1, 'IDN', 'Indonesia'),
(2, 'USA', 'United States'),
(3, 'JPN', 'Japan'),
(4, 'KOR', 'South Korea'),
(5, 'GBR', 'United Kingdom');

-- 2. SUBSCRIPTION PLANS DATA
INSERT INTO subscription_plans (plan_id, plan_name, monthly_price, max_concurrent_streams, max_resolution, has_ads) VALUES
(1, 'Mobile', 54000.00, 1, 'SD', FALSE),
(2, 'Basic Ad-Supported', 75000.00, 1, 'HD', TRUE),
(3, 'Standard', 120000.00, 2, 'HD', FALSE),
(4, 'Premium 4K', 186000.00, 4, '4K', FALSE);

-- 3. USERS DATA (10 Subscriber Accounts)
INSERT INTO users (user_id, email, password_hash, country_id, plan_id, account_status, created_at) VALUES
(1, 'budi.santoso@gmail.com', '$2a$12$e8Y1x9Z.K...hash1', 1, 4, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '60 days'),
(2, 'siti.rahma@yahoo.com', '$2a$12$e8Y1x9Z.K...hash2', 1, 3, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '45 days'),
(3, 'john.doe@gmail.com', '$2a$12$e8Y1x9Z.K...hash3', 2, 4, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '90 days'),
(4, 'kenji.sato@yahoo.co.jp', '$2a$12$e8Y1x9Z.K...hash4', 3, 3, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '30 days'),
(5, 'minho.kim@naver.com', '$2a$12$e8Y1x9Z.K...hash5', 4, 4, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '15 days'),
(6, 'sarah.smith@outlook.com', '$2a$12$e8Y1x9Z.K...hash6', 5, 2, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '20 days'),
(7, 'andri.wijaya@gmail.com', '$2a$12$e8Y1x9Z.K...hash7', 1, 1, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '10 days'),
(8, 'dewi.lestari@gmail.com', '$2a$12$e8Y1x9Z.K...hash8', 1, 3, 'SUSPENDED', CURRENT_TIMESTAMP - INTERVAL '120 days'),
(9, 'churned.user1@gmail.com', '$2a$12$e8Y1x9Z.K...hash9', 1, 3, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '180 days'),
(10, 'churned.user2@gmail.com', '$2a$12$e8Y1x9Z.K...hash10', 2, 4, 'ACTIVE', CURRENT_TIMESTAMP - INTERVAL '200 days');

-- 4. USER PROFILES DATA (15 Profiles across Accounts)
INSERT INTO user_profiles (profile_id, user_id, profile_name, is_kids, maturity_rating_limit) VALUES
(1, 1, 'Budi Utama', FALSE, 'TV-MA'),
(2, 1, 'Budi Kids', TRUE, 'G'),
(3, 2, 'Siti', FALSE, 'TV-MA'),
(4, 3, 'John Main', FALSE, 'R'),
(5, 3, 'Johnny Jr', TRUE, 'PG'),
(6, 4, 'Kenji', FALSE, 'TV-MA'),
(7, 5, 'Minho', FALSE, 'TV-MA'),
(8, 6, 'Sarah', FALSE, 'TV-MA'),
(9, 7, 'Andri Phone', FALSE, 'TV-14'),
(10, 8, 'Dewi Profile', FALSE, 'TV-MA'),
(11, 9, 'Inactive Profile 1', FALSE, 'TV-MA'),
(12, 10, 'Inactive Profile 2', FALSE, 'TV-MA'),
(13, 1, 'Budi Movie Night', FALSE, 'TV-MA'),
(14, 2, 'Siti Drama', FALSE, 'TV-14'),
(15, 3, 'John Family', TRUE, 'G');

-- 5. REGISTERED DEVICES DATA
INSERT INTO devices (device_id, user_id, device_name, device_type, os, last_used_at) VALUES
(1, 1, 'Budi Samsung 4K TV', 'SMART_TV', 'Tizen', CURRENT_TIMESTAMP),
(2, 1, 'Budi iPhone 15', 'MOBILE', 'iOS 17', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(3, 2, 'Siti iPad Air', 'TABLET', 'iPadOS 17', CURRENT_TIMESTAMP - INTERVAL '2 hours'),
(4, 3, 'John LG OLED TV', 'SMART_TV', 'webOS', CURRENT_TIMESTAMP),
(5, 4, 'Kenji PS5', 'CONSOLE', 'FreeBSD', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
(6, 7, 'Andri Xiaomi Phone', 'MOBILE', 'Android 14', CURRENT_TIMESTAMP);

-- 6. LANGUAGES DATA
INSERT INTO languages (language_id, language_code, language_name) VALUES
(1, 'ind', 'Indonesian'),
(2, 'eng', 'English'),
(3, 'jpn', 'Japanese'),
(4, 'kor', 'Korean');

-- 7. CONTENTS BASE DATA (10 Titles: 5 Movies, 5 Series)
INSERT INTO contents (content_id, title, description, release_year, age_rating, content_type) VALUES
(1, 'Inception', 'A thief who steals corporate secrets through dream-sharing technology.', 2010, 'PG-13', 'MOVIE'),
(2, 'The Dark Knight', 'Batman accepts his greatest psychological and physical tests.', 2008, 'PG-13', 'MOVIE'),
(3, 'Stranger Things', 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments.', 2016, 'TV-14', 'SERIES'),
(4, 'Squid Game', 'Hundreds of cash-strapped players accept a strange invitation to compete in children games.', 2021, 'TV-MA', 'SERIES'),
(5, 'Pengabdi Setan 2', 'A family is haunted in a budget apartment building.', 2022, 'R', 'MOVIE'),
(6, 'Attack on Titan', 'Humanity fights against giant humanoid Titans.', 2013, 'TV-MA', 'SERIES'),
(7, 'Interstellar', 'A team of explorers travel through a wormhole in space.', 2014, 'PG-13', 'MOVIE'),
(8, 'Breaking Bad', 'A high school chemistry teacher turned drug lord.', 2008, 'TV-MA', 'SERIES'),
(9, 'Laskar Pelangi', 'Ten students and their two inspiring teachers in Belitung.', 2008, 'G', 'MOVIE'),
(10, 'Money Heist', 'An unusual group of robbers attempt to carry out the most perfect robbery in Spanish history.', 2017, 'TV-MA', 'SERIES');

-- 8. MOVIES DETAIL DATA
INSERT INTO movies (movie_id, content_id, duration_minutes, video_stream_url) VALUES
(1, 1, 148, 'https://cdn.streaming.com/hls/inception/master.m3u8'),
(2, 2, 152, 'https://cdn.streaming.com/hls/dark_knight/master.m3u8'),
(3, 5, 119, 'https://cdn.streaming.com/hls/pengabdi_setan_2/master.m3u8'),
(4, 7, 169, 'https://cdn.streaming.com/hls/interstellar/master.m3u8'),
(5, 9, 125, 'https://cdn.streaming.com/hls/laskar_pelangi/master.m3u8');

-- 9. SERIES & EPISODES DATA
INSERT INTO series (series_id, content_id, total_seasons) VALUES
(1, 3, 4), -- Stranger Things
(2, 4, 1), -- Squid Game
(3, 6, 4), -- Attack on Titan
(4, 8, 5), -- Breaking Bad
(5, 10, 5); -- Money Heist

INSERT INTO episodes (episode_id, series_id, season_number, episode_number, title, duration_minutes, video_stream_url) VALUES
(1, 1, 1, 1, 'Chapter One: The Vanishing of Will Byers', 48, 'https://cdn.streaming.com/hls/st_s1e1/master.m3u8'),
(2, 1, 1, 2, 'Chapter Two: The Weirdo on Maple Street', 55, 'https://cdn.streaming.com/hls/st_s1e2/master.m3u8'),
(3, 2, 1, 1, 'Red Light, Green Light', 60, 'https://cdn.streaming.com/hls/sq_s1e1/master.m3u8'),
(4, 3, 1, 1, 'To You, in 2000 Years', 24, 'https://cdn.streaming.com/hls/aot_s1e1/master.m3u8'),
(5, 4, 1, 1, 'Pilot', 58, 'https://cdn.streaming.com/hls/bb_s1e1/master.m3u8');

-- 10. GENRES & CONTENT GENRES DATA
INSERT INTO genres (genre_id, genre_name) VALUES
(1, 'Action'), (2, 'Sci-Fi'), (3, 'Drama'), (4, 'Horror'), (5, 'Thriller'), (6, 'Anime');

INSERT INTO content_genres (content_id, genre_id) VALUES
(1, 1), (1, 2), -- Inception: Action, Sci-Fi
(2, 1), (2, 5), -- Dark Knight: Action, Thriller
(3, 2), (3, 4), -- Stranger Things: Sci-Fi, Horror
(4, 3), (4, 5), -- Squid Game: Drama, Thriller
(5, 4),         -- Pengabdi Setan 2: Horror
(6, 1), (6, 6), -- Attack on Titan: Action, Anime
(7, 2), (7, 3); -- Interstellar: Sci-Fi, Drama

-- 11. CONTENT PROVIDERS & LICENSES DATA
INSERT INTO content_providers (provider_id, provider_name, contact_email) VALUES
(1, 'Warner Bros. Discovery', 'licensing@warnerbros.com'),
(2, 'Rapi Films', 'licensing@rapifilms.com'),
(3, 'Netflix Studios', 'licensing@netflix.com');

INSERT INTO content_licenses (license_id, content_id, provider_id, country_id, start_date, end_date, license_cost) VALUES
(1, 1, 1, 1, '2024-01-01', '2027-12-31', 50000.00), -- Inception in IDN
(2, 1, 1, 2, '2024-01-01', '2027-12-31', 150000.00), -- Inception in USA
(3, 5, 2, 1, '2023-08-01', '2026-08-01', 30000.00),  -- Pengabdi Setan 2 in IDN
(4, 3, 3, 1, '2020-01-01', '2030-12-31', 200000.00); -- Stranger Things in IDN

-- 12. STREAMING SESSIONS TELEMETRY DATA (> 20 Rows)
INSERT INTO streaming_sessions (session_id, profile_id, content_id, episode_id, device_id, start_time, end_time, watch_duration_seconds, is_completed, max_bitrate_kbps, user_ip) VALUES
(1, 1, 1, NULL, 1, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '148 minutes', 8880, TRUE, 15000, '182.1.2.3'),
(2, 1, 2, NULL, 1, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '152 minutes', 9120, TRUE, 15000, '182.1.2.3'),
(3, 1, 3, 1, 1, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '48 minutes', 2880, TRUE, 12000, '182.1.2.3'),
(4, 1, 3, 2, 1, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '55 minutes', 3300, TRUE, 12000, '182.1.2.3'),
(5, 3, 1, NULL, 3, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 minutes', 600, FALSE, 4000, '182.5.6.7'),
(6, 3, 5, NULL, 3, CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '119 minutes', 7140, TRUE, 8000, '182.5.6.7'),
(7, 4, 1, NULL, 4, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '148 minutes', 8880, TRUE, 25000, '64.12.3.4'),
(8, 4, 7, NULL, 4, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '169 minutes', 10140, TRUE, 25000, '64.12.3.4'),
(9, 6, 6, 4, 5, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '24 minutes', 1440, TRUE, 10000, '133.2.1.1'),
(10, 7, 4, 3, 6, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '60 minutes', 3600, TRUE, 12000, '211.4.3.2'),
(11, 9, 9, NULL, 6, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '125 minutes', 7500, TRUE, 3000, '180.2.1.1'),
(12, 1, 5, NULL, 2, CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '6 hours' + INTERVAL '119 minutes', 7140, TRUE, 8000, '182.1.2.3'),
(13, 3, 3, 1, 3, CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP - INTERVAL '12 hours' + INTERVAL '48 minutes', 2880, TRUE, 6000, '182.5.6.7'),
(14, 4, 2, NULL, 4, CURRENT_TIMESTAMP - INTERVAL '8 hours', CURRENT_TIMESTAMP - INTERVAL '8 hours' + INTERVAL '152 minutes', 9120, TRUE, 25000, '64.12.3.4'),
(15, 6, 1, NULL, 5, CURRENT_TIMESTAMP - INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '10 hours' + INTERVAL '148 minutes', 8880, TRUE, 12000, '133.2.1.1'),
(16, 7, 3, 1, 6, CURRENT_TIMESTAMP - INTERVAL '4 hours', CURRENT_TIMESTAMP - INTERVAL '4 hours' + INTERVAL '48 minutes', 2880, TRUE, 10000, '211.4.3.2'),
(17, 1, 7, NULL, 1, CURRENT_TIMESTAMP - INTERVAL '3 hours', CURRENT_TIMESTAMP - INTERVAL '3 hours' + INTERVAL '169 minutes', 10140, TRUE, 20000, '182.1.2.3'),
(18, 3, 2, NULL, 3, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours' + INTERVAL '152 minutes', 9120, TRUE, 8000, '182.5.6.7'),
(19, 4, 5, NULL, 4, CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '1 hour' + INTERVAL '5 minutes', 300, FALSE, 25000, '64.12.3.4'),
(20, 6, 7, NULL, 5, CURRENT_TIMESTAMP - INTERVAL '30 minutes', CURRENT_TIMESTAMP, 1800, FALSE, 12000, '133.2.1.1'),
(21, 11, 1, NULL, 6, CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_TIMESTAMP - INTERVAL '25 days' + INTERVAL '100 minutes', 6000, FALSE, 5000, '180.1.1.1'),
(22, 12, 3, 1, 6, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '48 minutes', 2880, TRUE, 5000, '64.1.1.1');

-- 13. RATINGS DATA
INSERT INTO ratings (profile_id, content_id, rating_score, reviewed_at) VALUES
(1, 1, 5, CURRENT_TIMESTAMP - INTERVAL '1 day'),
(1, 2, 5, CURRENT_TIMESTAMP - INTERVAL '2 days'),
(3, 5, 4, CURRENT_TIMESTAMP - INTERVAL '4 days'),
(4, 1, 5, CURRENT_TIMESTAMP - INTERVAL '1 day'),
(4, 7, 5, CURRENT_TIMESTAMP - INTERVAL '2 days'),
(6, 6, 5, CURRENT_TIMESTAMP - INTERVAL '1 day');

-- 14. WATCHLISTS DATA
INSERT INTO watchlists (profile_id, content_id, added_at) VALUES
(1, 7, CURRENT_TIMESTAMP),
(1, 10, CURRENT_TIMESTAMP),
(3, 1, CURRENT_TIMESTAMP),
(4, 3, CURRENT_TIMESTAMP);
