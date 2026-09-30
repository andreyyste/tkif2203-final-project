-- ============================================================================
-- FINAL PROJECT: VOD STREAMING SERVICE DATABASE SCHEMA (PostgreSQL DDL)
-- Course: TKIF2203 - Database Technology
-- Instructor: Dr. Guntur D Putra
-- Student: Andrey (TKIF2203)
-- ============================================================================

-- 1. CLEANUP & EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS daily_content_performance CASCADE;
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS watchlists CASCADE;
DROP TABLE IF EXISTS streaming_sessions CASCADE;
DROP TABLE IF EXISTS content_licenses CASCADE;
DROP TABLE IF EXISTS content_providers CASCADE;
DROP TABLE IF EXISTS content_cast CASCADE;
DROP TABLE IF EXISTS cast_members CASCADE;
DROP TABLE IF EXISTS content_genres CASCADE;
DROP TABLE IF EXISTS genres CASCADE;
DROP TABLE IF EXISTS episodes CASCADE;
DROP TABLE IF EXISTS series CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS contents CASCADE;
DROP TABLE IF EXISTS languages CASCADE;
DROP TABLE IF EXISTS payment_transactions CASCADE;
DROP TABLE IF EXISTS devices CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS subscription_plans CASCADE;
DROP TABLE IF EXISTS countries CASCADE;

-- ============================================================================
-- 2. DOMAIN 1: USER, MONETIZATION & DEVICE MANAGEMENT
-- ============================================================================

-- 2.1 Countries Table (Territory & Licensing boundary)
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_code VARCHAR(3) UNIQUE NOT NULL,
    country_name VARCHAR(100) NOT NULL
);

-- 2.2 Subscription Plans Table
CREATE TABLE subscription_plans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    monthly_price NUMERIC(10,2) NOT NULL CHECK (monthly_price >= 0),
    max_concurrent_streams INT NOT NULL DEFAULT 1 CHECK (max_concurrent_streams > 0),
    max_resolution VARCHAR(10) NOT NULL CHECK (max_resolution IN ('SD', 'HD', '4K')),
    has_ads BOOLEAN NOT NULL DEFAULT FALSE
);

-- 2.3 Account Users Table (Billing & Account Holder)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    country_id INT NOT NULL REFERENCES countries(country_id) ON DELETE RESTRICT,
    plan_id INT REFERENCES subscription_plans(plan_id) ON DELETE SET NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (account_status IN ('ACTIVE', 'SUSPENDED', 'CANCELLED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2.4 User Profiles Table (1 Account -> Multiple Viewer Profiles)
CREATE TABLE user_profiles (
    profile_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    profile_name VARCHAR(50) NOT NULL,
    is_kids BOOLEAN NOT NULL DEFAULT FALSE,
    maturity_rating_limit VARCHAR(10) DEFAULT 'TV-MA' CHECK (maturity_rating_limit IN ('G', 'PG', 'PG-13', 'R', 'TV-Y', 'TV-14', 'TV-MA')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2.5 Registered Devices Table
CREATE TABLE devices (
    device_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL CHECK (device_type IN ('SMART_TV', 'MOBILE', 'TABLET', 'WEB', 'CONSOLE')),
    os VARCHAR(50),
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2.6 Payment Transactions Table (Financial Audit Trail)
CREATE TABLE payment_transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE SET NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('CREDIT_CARD', 'E_WALLET', 'BANK_TRANSFER', 'PAYPAL')),
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS' CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 3. DOMAIN 2: MEDIA CATALOG & METADATA
-- ============================================================================

-- 3.1 Languages Table
CREATE TABLE languages (
    language_id SERIAL PRIMARY KEY,
    language_code VARCHAR(10) UNIQUE NOT NULL,
    language_name VARCHAR(50) NOT NULL
);

-- 3.2 Contents Base Table (Class Table Inheritance Parent)
CREATE TABLE contents (
    content_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_year INT CHECK (release_year >= 1900),
    age_rating VARCHAR(10) NOT NULL CHECK (age_rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17', 'TV-Y', 'TV-14', 'TV-MA')),
    content_type VARCHAR(10) NOT NULL CHECK (content_type IN ('MOVIE', 'SERIES')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.3 Standalone Movies Table (1:1 with contents)
CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    content_id INT UNIQUE NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    video_stream_url TEXT NOT NULL
);

-- 3.4 Episodic Series Table (1:1 with contents)
CREATE TABLE series (
    series_id SERIAL PRIMARY KEY,
    content_id INT UNIQUE NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    total_seasons INT NOT NULL DEFAULT 1 CHECK (total_seasons > 0)
);

-- 3.5 Series Episodes Table (1:N with series)
CREATE TABLE episodes (
    episode_id SERIAL PRIMARY KEY,
    series_id INT NOT NULL REFERENCES series(series_id) ON DELETE CASCADE,
    season_number INT NOT NULL CHECK (season_number > 0),
    episode_number INT NOT NULL CHECK (episode_number > 0),
    title VARCHAR(255) NOT NULL,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    video_stream_url TEXT NOT NULL,
    CONSTRAINT unq_series_season_episode UNIQUE (series_id, season_number, episode_number)
);

-- 3.6 Genres Table & Junction Table (Many-to-Many)
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE content_genres (
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    genre_id INT NOT NULL REFERENCES genres(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, genre_id)
);

-- 3.7 Cast & Crew Members & Junction Table (Many-to-Many)
CREATE TABLE cast_members (
    cast_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    role_type VARCHAR(50) DEFAULT 'ACTOR' CHECK (role_type IN ('ACTOR', 'DIRECTOR', 'PRODUCER', 'WRITER'))
);

CREATE TABLE content_cast (
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    cast_id INT NOT NULL REFERENCES cast_members(cast_id) ON DELETE CASCADE,
    character_name VARCHAR(100),
    PRIMARY KEY (content_id, cast_id)
);

-- ============================================================================
-- 4. DOMAIN 3: CONTENT PROVIDERS & REGIONAL LICENSING
-- ============================================================================

-- 4.1 Studio Content Providers Table
CREATE TABLE content_providers (
    provider_id SERIAL PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(255)
);

-- 4.2 Content Regional Licensing Windows Table (Geo-restriction enforcement)
CREATE TABLE content_licenses (
    license_id SERIAL PRIMARY KEY,
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    provider_id INT NOT NULL REFERENCES content_providers(provider_id) ON DELETE RESTRICT,
    country_id INT NOT NULL REFERENCES countries(country_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    license_cost NUMERIC(12,2) CHECK (license_cost >= 0),
    CONSTRAINT chk_license_dates CHECK (end_date >= start_date)
);

-- ============================================================================
-- 5. DOMAIN 4: PLAYBACK TELEMETRY, RATINGS & WATCHLISTS
-- ============================================================================

-- 5.1 High-Cardinality Streaming Telemetry Log Table
CREATE TABLE streaming_sessions (
    session_id BIGSERIAL PRIMARY KEY,
    profile_id INT NOT NULL REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    episode_id INT REFERENCES episodes(episode_id) ON DELETE CASCADE,
    device_id INT REFERENCES devices(device_id) ON DELETE SET NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP WITH TIME ZONE,
    watch_duration_seconds INT NOT NULL DEFAULT 0 CHECK (watch_duration_seconds >= 0),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    max_bitrate_kbps INT CHECK (max_bitrate_kbps >= 0),
    user_ip VARCHAR(45)
);

-- 5.2 User Profile Watchlists (Many-to-Many)
CREATE TABLE watchlists (
    profile_id INT NOT NULL REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id, content_id)
);

-- 5.3 Content Ratings & Reviews (Many-to-Many)
CREATE TABLE ratings (
    profile_id INT NOT NULL REFERENCES user_profiles(profile_id) ON DELETE CASCADE,
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    rating_score INT NOT NULL CHECK (rating_score BETWEEN 1 AND 5),
    reviewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (profile_id, content_id)
);

-- ============================================================================
-- 6. DOMAIN 5: ANALYTICS AGGREGATE TABLE (OLAP DENORMALIZATION)
-- ============================================================================

-- 6.1 Daily Content Performance Aggregate Summary Table
CREATE TABLE daily_content_performance (
    stat_date DATE NOT NULL,
    content_id INT NOT NULL REFERENCES contents(content_id) ON DELETE CASCADE,
    country_id INT NOT NULL REFERENCES countries(country_id) ON DELETE CASCADE,
    total_plays INT DEFAULT 0 CHECK (total_plays >= 0),
    total_watch_hours NUMERIC(10,2) DEFAULT 0 CHECK (total_watch_hours >= 0),
    completion_count INT DEFAULT 0 CHECK (completion_count >= 0),
    unique_viewers INT DEFAULT 0 CHECK (unique_viewers >= 0),
    PRIMARY KEY (stat_date, content_id, country_id)
);

-- ============================================================================
-- 7. PERFORMANCE INDEXES FOR ANALYTIC WORKLOADS
-- ============================================================================

-- Composite index for playback aggregation by content and time range
CREATE INDEX idx_sessions_content_time ON streaming_sessions(content_id, start_time);

-- Index for user activity history lookup
CREATE INDEX idx_sessions_profile_time ON streaming_sessions(profile_id, start_time DESC);

-- Composite index for country & subscription tier filtering
CREATE INDEX idx_users_country_plan ON users(country_id, plan_id);

-- Index for geo-licensing validity verification
CREATE INDEX idx_licenses_geo ON content_licenses(country_id, start_date, end_date);

-- Index for episode lookup by series
CREATE INDEX idx_episodes_series ON episodes(series_id, season_number, episode_number);
