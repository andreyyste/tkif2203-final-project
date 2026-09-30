-- ============================================================================
-- FINAL PROJECT: VOD STREAMING SERVICE ANALYTICS QUERIES (PostgreSQL OLAP)
-- Course: TKIF2203 - Database Technology
-- Instructor: Dr. Guntur D Putra
-- Student: Andrey (TKIF2203)
-- ============================================================================

-- ============================================================================
-- SECTION A: ANALYTICS AGGREGATE SUMMARY TABLE DDL & ETL PIPELINE
-- ============================================================================

-- 1. ETL SQL: Populate / Refresh Daily Content Performance Aggregates
INSERT INTO daily_content_performance (stat_date, content_id, country_id, total_plays, total_watch_hours, completion_count, unique_viewers)
SELECT 
    DATE(s.start_time) AS stat_date,
    s.content_id,
    u.country_id,
    COUNT(s.session_id) AS total_plays,
    ROUND(SUM(s.watch_duration_seconds) / 3600.0, 2) AS total_watch_hours,
    COUNT(CASE WHEN s.is_completed THEN 1 END) AS completion_count,
    COUNT(DISTINCT s.profile_id) AS unique_viewers
FROM streaming_sessions s
JOIN user_profiles p ON s.profile_id = p.profile_id
JOIN users u ON p.user_id = u.user_id
GROUP BY DATE(s.start_time), s.content_id, u.country_id
ON CONFLICT (stat_date, content_id, country_id) 
DO UPDATE SET 
    total_plays = EXCLUDED.total_plays,
    total_watch_hours = EXCLUDED.total_watch_hours,
    completion_count = EXCLUDED.completion_count,
    unique_viewers = EXCLUDED.unique_viewers;


-- ============================================================================
-- SECTION B: 6 CORE BUSINESS ANALYTICS QUERIES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- QUERY 1: Daily Active Users (DAU) & Active Devices Telemetry
-- Business Purpose: Measure daily user engagement and active device counts.
-- ----------------------------------------------------------------------------
SELECT 
    DATE(start_time) AS activity_date,
    COUNT(DISTINCT profile_id) AS daily_active_profiles,
    COUNT(DISTINCT device_id) AS daily_active_devices,
    COUNT(session_id) AS total_streaming_sessions,
    ROUND(SUM(watch_duration_seconds) / 3600.0, 2) AS total_platform_watch_hours
FROM streaming_sessions
GROUP BY DATE(start_time)
ORDER BY activity_date DESC;

-- ----------------------------------------------------------------------------
-- QUERY 2: Top Content by Watch Duration & Region (Past 30 Days)
-- Business Purpose: Help content acquisition team identify regional content demand.
-- ----------------------------------------------------------------------------
SELECT 
    c.country_name,
    cnt.title,
    cnt.content_type,
    COUNT(s.session_id) AS total_plays,
    ROUND(SUM(s.watch_duration_seconds) / 3600.0, 2) AS total_watch_hours,
    COUNT(DISTINCT s.profile_id) AS unique_viewers
FROM streaming_sessions s
JOIN user_profiles p ON s.profile_id = p.profile_id
JOIN users u ON p.user_id = u.user_id
JOIN countries c ON u.country_id = c.country_id
JOIN contents cnt ON s.content_id = cnt.content_id
WHERE s.start_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.country_name, cnt.title, cnt.content_type
ORDER BY c.country_name, total_watch_hours DESC;

-- ----------------------------------------------------------------------------
-- QUERY 3: User Retention Cohort Analysis (Monthly Registration Cohorts)
-- Business Purpose: Evaluate user retention percentages across registration months.
-- ----------------------------------------------------------------------------
WITH user_cohorts AS (
    SELECT 
        user_id,
        DATE_TRUNC('month', created_at) AS cohort_month
    FROM users
),
user_activity AS (
    SELECT DISTINCT
        p.user_id,
        DATE_TRUNC('month', s.start_time) AS activity_month
    FROM streaming_sessions s
    JOIN user_profiles p ON s.profile_id = p.profile_id
)
SELECT 
    TO_CHAR(uc.cohort_month, 'YYYY-MM') AS cohort_month,
    TO_CHAR(ua.activity_month, 'YYYY-MM') AS activity_month,
    COUNT(DISTINCT uc.user_id) AS total_cohort_size,
    COUNT(DISTINCT ua.user_id) AS retained_active_users,
    ROUND((COUNT(DISTINCT ua.user_id)::NUMERIC / COUNT(DISTINCT uc.user_id)) * 100, 2) AS retention_rate_pct
FROM user_cohorts uc
LEFT JOIN user_activity ua ON uc.user_id = ua.user_id AND ua.activity_month >= uc.cohort_month
GROUP BY uc.cohort_month, ua.activity_month
ORDER BY uc.cohort_month, ua.activity_month;

-- ----------------------------------------------------------------------------
-- QUERY 4: Drop-off & Completion Rate Analysis (< 20% Duration Watched)
-- Business Purpose: Identify content with high early viewer drop-off rates.
-- ----------------------------------------------------------------------------
SELECT 
    cnt.title,
    cnt.content_type,
    COUNT(s.session_id) AS total_starts,
    COUNT(CASE WHEN s.is_completed THEN 1 END) AS total_completions,
    COUNT(CASE WHEN (s.watch_duration_seconds / NULLIF(COALESCE(m.duration_minutes, e.duration_minutes) * 60, 0)) < 0.20 THEN 1 END) AS early_dropoffs,
    ROUND(
        (COUNT(CASE WHEN (s.watch_duration_seconds / NULLIF(COALESCE(m.duration_minutes, e.duration_minutes) * 60, 0)) < 0.20 THEN 1 END)::NUMERIC 
        / NULLIF(COUNT(s.session_id), 0)) * 100, 2
    ) AS dropoff_rate_pct
FROM streaming_sessions s
JOIN contents cnt ON s.content_id = cnt.content_id
LEFT JOIN movies m ON cnt.content_id = m.content_id
LEFT JOIN episodes e ON s.episode_id = e.episode_id
GROUP BY cnt.title, cnt.content_type
HAVING COUNT(s.session_id) > 0
ORDER BY dropoff_rate_pct DESC;

-- ----------------------------------------------------------------------------
-- QUERY 5: Churn Risk Indicator Query (Active Subscribers with No Streams in 14+ Days)
-- Business Purpose: Trigger re-engagement emails for inactive paid subscribers.
-- ----------------------------------------------------------------------------
SELECT 
    u.user_id,
    u.email,
    sp.plan_name,
    c.country_name,
    MAX(s.start_time) AS last_streaming_timestamp,
    COALESCE(CURRENT_DATE - DATE(MAX(s.start_time)), 999) AS days_inactive
FROM users u
JOIN subscription_plans sp ON u.plan_id = sp.plan_id
JOIN countries c ON u.country_id = c.country_id
JOIN user_profiles p ON u.user_id = p.user_id
LEFT JOIN streaming_sessions s ON p.profile_id = s.profile_id
WHERE u.account_status = 'ACTIVE'
GROUP BY u.user_id, u.email, sp.plan_name, c.country_name
HAVING MAX(s.start_time) < CURRENT_DATE - INTERVAL '14 days' OR MAX(s.start_time) IS NULL
ORDER BY days_inactive DESC;

-- ----------------------------------------------------------------------------
-- QUERY 6: Recommendation Engine Co-Watching Matrix (Item Similarity)
-- Business Purpose: Generate "People who watched X also watched Y" recommendation signals.
-- ----------------------------------------------------------------------------
SELECT 
    c1.title AS content_a,
    c2.title AS content_b,
    COUNT(DISTINCT s1.profile_id) AS co_watch_profile_count
FROM streaming_sessions s1
JOIN streaming_sessions s2 ON s1.profile_id = s2.profile_id AND s1.content_id < s2.content_id
JOIN contents c1 ON s1.content_id = c1.content_id
JOIN contents c2 ON s2.content_id = c2.content_id
WHERE ABS(EXTRACT(EPOCH FROM (s1.start_time - s2.start_time))) <= 604800 -- Watched within 7 days window
GROUP BY c1.title, c2.title
ORDER BY co_watch_profile_count DESC
LIMIT 10;
