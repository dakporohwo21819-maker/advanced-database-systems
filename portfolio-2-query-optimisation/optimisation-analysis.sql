-- =============================================================================
-- Shepherd App, Portfolio 2: Query Optimisation Evidence
-- EXPLAIN ANALYZE before and after indexing
-- =============================================================================

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- TEST CASE: Donation lookup by date range and type
-- This query simulates a real report: "Show all tithes for September 2026"
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- BEFORE: Run EXPLAIN ANALYZE without a targeted index
EXPLAIN ANALYZE
SELECT d.donation_id, m.first_name || ' ' || m.last_name AS member,
       d.amount, d.donation_date
FROM   donations d
LEFT JOIN members m ON d.member_id = m.member_id
WHERE  d.donation_type = 'tithe'
  AND  d.donation_date BETWEEN '2026-09-01' AND '2026-09-30'
ORDER  BY d.donation_date;

-- CREATE a composite index targeting this query pattern
CREATE INDEX idx_donations_type_date ON donations(donation_type, donation_date);

-- AFTER: Re-run the same EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT d.donation_id, m.first_name || ' ' || m.last_name AS member,
       d.amount, d.donation_date
FROM   donations d
LEFT JOIN members m ON d.member_id = m.member_id
WHERE  d.donation_type = 'tithe'
  AND  d.donation_date BETWEEN '2026-09-01' AND '2026-09-30'
ORDER  BY d.donation_date;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- TEST CASE 2: Attendance count per member (frequent GROUP BY)
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- BEFORE
EXPLAIN ANALYZE
SELECT m.first_name || ' ' || m.last_name AS member_name,
       COUNT(*) AS total_events
FROM   attendance a
JOIN   members m ON a.member_id = m.member_id
GROUP  BY m.member_id, m.first_name, m.last_name
ORDER  BY total_events DESC;

-- CREATE covering index on attendance(member_id)
CREATE INDEX idx_attendance_member ON attendance(member_id);

-- AFTER
EXPLAIN ANALYZE
SELECT m.first_name || ' ' || m.last_name AS member_name,
       COUNT(*) AS total_events
FROM   attendance a
JOIN   members m ON a.member_id = m.member_id
GROUP  BY m.member_id, m.first_name, m.last_name
ORDER  BY total_events DESC;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- TEST CASE 3: Complex engagement query (Query 9), execution plan
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
EXPLAIN ANALYZE
WITH att_score AS (
    SELECT member_id, COUNT(*) AS events_attended
    FROM   attendance GROUP BY member_id
),
don_score AS (
    SELECT member_id, COUNT(*) AS donation_count, SUM(amount) AS total_given
    FROM   donations WHERE member_id IS NOT NULL
    GROUP  BY member_id
),
grp_score AS (
    SELECT member_id, COUNT(*) AS groups_joined
    FROM   group_members GROUP BY member_id
)
SELECT m.member_id,
       m.first_name || ' ' || m.last_name AS member_name,
       COALESCE(a.events_attended, 0) AS events,
       COALESCE(ds.donation_count, 0) AS donations,
       COALESCE(g.groups_joined, 0)   AS groups
FROM   members m
LEFT JOIN att_score  a  ON m.member_id = a.member_id
LEFT JOIN don_score  ds ON m.member_id = ds.member_id
LEFT JOIN grp_score  g  ON m.member_id = g.member_id
WHERE  m.status = 'active';
