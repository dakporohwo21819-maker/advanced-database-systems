-- =============================================================================
-- Shepherd App, Portfolio 2: Query Processing and Optimisation
-- 10 SQL Queries of increasing complexity
-- =============================================================================

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 1: Basic SELECT with WHERE and ORDER BY
-- Purpose: List all active members of Grace Chapel Lagos, sorted by join date
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT m.member_id, m.first_name, m.last_name, m.gender, m.member_since
FROM   members m
JOIN   churches c ON m.church_id = c.church_id
WHERE  c.name = 'Grace Chapel Lagos'
  AND  m.status = 'active'
ORDER  BY m.member_since;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 2: Aggregation with GROUP BY
-- Purpose: Total donations per church
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT c.name AS church,
       COUNT(d.donation_id)   AS total_donations,
       SUM(d.amount)          AS total_amount,
       ROUND(AVG(d.amount),2) AS avg_donation
FROM   donations d
JOIN   churches c ON d.church_id = c.church_id
GROUP  BY c.name
ORDER  BY total_amount DESC;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 3: Multi-table JOIN
-- Purpose: Attendance register for a specific event with member details
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT e.title, e.start_time::date AS event_date,
       m.first_name || ' ' || m.last_name AS member_name,
       a.check_in_time::time AS checked_in,
       a.check_in_method
FROM   attendance a
JOIN   events  e ON a.event_id  = e.event_id
JOIN   members m ON a.member_id = m.member_id
WHERE  e.event_id = 1
ORDER  BY a.check_in_time;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 4: Subquery
-- Purpose: Members who have NEVER made a donation
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT m.member_id, m.first_name, m.last_name, c.name AS church
FROM   members m
JOIN   churches c ON m.church_id = c.church_id
WHERE  m.member_id NOT IN (
           SELECT DISTINCT member_id
           FROM   donations
           WHERE  member_id IS NOT NULL
       )
ORDER  BY c.name, m.last_name;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 5: Correlated subquery
-- Purpose: Each member's most recent donation
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT m.first_name || ' ' || m.last_name AS member_name,
       d.amount, d.donation_type, d.donation_date
FROM   donations d
JOIN   members m ON d.member_id = m.member_id
WHERE  d.donation_date = (
           SELECT MAX(d2.donation_date)
           FROM   donations d2
           WHERE  d2.member_id = d.member_id
       )
ORDER  BY d.donation_date DESC;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 6: CTE (Common Table Expression)
-- Purpose: Attendance rate per event (attendees vs total active members)
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
WITH active_counts AS (
    SELECT church_id, COUNT(*) AS active_members
    FROM   members
    WHERE  status = 'active'
    GROUP  BY church_id
),
event_attendance AS (
    SELECT e.event_id, e.title, e.church_id, e.start_time::date AS event_date,
           COUNT(a.attendance_id) AS attendees
    FROM   events e
    LEFT JOIN attendance a ON e.event_id = a.event_id
    GROUP  BY e.event_id, e.title, e.church_id, e.start_time
)
SELECT ea.title, ea.event_date,
       c.name AS church,
       ea.attendees,
       ac.active_members,
       ROUND(100.0 * ea.attendees / ac.active_members, 1) AS attendance_pct
FROM   event_attendance ea
JOIN   active_counts ac ON ea.church_id = ac.church_id
JOIN   churches c ON ea.church_id = c.church_id
ORDER  BY ea.event_date, c.name;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 7: Window function, RANK
-- Purpose: Rank members by total donation amount within each church
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT church, member_name, total_donated,
       RANK() OVER (PARTITION BY church ORDER BY total_donated DESC) AS donation_rank
FROM (
    SELECT c.name AS church,
           m.first_name || ' ' || m.last_name AS member_name,
           SUM(d.amount) AS total_donated
    FROM   donations d
    JOIN   members  m ON d.member_id = m.member_id
    JOIN   churches c ON d.church_id = c.church_id
    GROUP  BY c.name, m.first_name, m.last_name
) sub
ORDER BY church, donation_rank;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 8: Window function, Running total
-- Purpose: Running total of donations over time for Grace Chapel
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT donation_date,
       SUM(amount) AS daily_total,
       SUM(SUM(amount)) OVER (ORDER BY donation_date) AS running_total
FROM   donations
WHERE  church_id = 1
GROUP  BY donation_date
ORDER  BY donation_date;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 9: Complex CTE + CASE expression
-- Purpose: Member engagement score (attendance + donations + group membership)
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
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
       c.name AS church,
       COALESCE(a.events_attended, 0)  AS events,
       COALESCE(ds.donation_count, 0)  AS donations,
       COALESCE(g.groups_joined, 0)    AS groups,
       CASE
           WHEN COALESCE(a.events_attended,0) >= 3
                AND COALESCE(ds.donation_count,0) >= 2
                AND COALESCE(g.groups_joined,0) >= 1 THEN 'Highly Engaged'
           WHEN COALESCE(a.events_attended,0) >= 1
                OR  COALESCE(ds.donation_count,0) >= 1 THEN 'Moderately Engaged'
           ELSE 'Low Engagement'
       END AS engagement_level
FROM   members m
JOIN   churches  c  ON m.church_id = c.church_id
LEFT JOIN att_score  a  ON m.member_id = a.member_id
LEFT JOIN don_score  ds ON m.member_id = ds.member_id
LEFT JOIN grp_score  g  ON m.member_id = g.member_id
WHERE  m.status = 'active'
ORDER  BY engagement_level, c.name, m.last_name;

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- QUERY 10: Pledge fulfilment analysis with percentage and status
-- Purpose: Show pledge progress with calculated remaining balance
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
SELECT m.first_name || ' ' || m.last_name AS member_name,
       c.name AS church,
       p.campaign,
       p.amount_pledged,
       p.amount_fulfilled,
       p.amount_pledged - p.amount_fulfilled AS remaining,
       ROUND(100.0 * p.amount_fulfilled / p.amount_pledged, 1) AS pct_fulfilled,
       p.due_date,
       CASE
           WHEN p.status = 'fulfilled' THEN 'Completed'
           WHEN p.due_date < CURRENT_DATE AND p.amount_fulfilled < p.amount_pledged THEN 'OVERDUE'
           ELSE 'On Track'
       END AS progress
FROM   pledges p
JOIN   members  m ON p.member_id = m.member_id
JOIN   churches c ON p.church_id = c.church_id
ORDER  BY p.due_date, pct_fulfilled;
