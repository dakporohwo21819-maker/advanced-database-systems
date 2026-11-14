# Portfolio 2: Query Processing and Optimisation

## Overview

This portfolio demonstrates SQL query writing, execution plan analysis, and index-based optimisation using the **Shepherd App** database (PostgreSQL 16).

## Files

| File | Description |
|---|---|
| `seed-data.sql` | Inserts realistic test data: 3 churches, 6 users, 30 members, 8 groups, 13 events, 51 attendance records, 25 donations, 6 pledges, 4 communications |
| `queries.sql` | 10 SQL queries of increasing complexity |
| `optimisation-analysis.sql` | EXPLAIN ANALYZE before/after adding indexes |
| `explain-output.txt` | Captured execution plan output |

## Query Summary

| # | Technique | Purpose |
|---|---|---|
| Q1 | SELECT + JOIN + WHERE + ORDER BY | List active members of a specific church |
| Q2 | GROUP BY + Aggregates (COUNT, SUM, AVG) | Total donations per church |
| Q3 | Multi-table JOIN (3 tables) | Attendance register for an event |
| Q4 | Subquery (NOT IN) | Members who never donated |
| Q5 | Correlated subquery | Each member's most recent donation |
| Q6 | CTE (WITH clause) | Attendance rate per event |
| Q7 | Window function (RANK, PARTITION BY) | Rank donors within each church |
| Q8 | Window function (running total) | Cumulative donations over time |
| Q9 | Multiple CTEs + CASE + LEFT JOINs | Member engagement scoring |
| Q10 | Calculated columns + CASE | Pledge fulfilment progress report |

## Optimisation Analysis

### Test Case 1: Donation lookup by type and date

**Query:** Retrieve all tithes for September 2026.

**Before index:** Sequential scan on `donations`, estimated cost 21.70, execution time ~0.097 ms.

**Index added:** `CREATE INDEX idx_donations_type_date ON donations(donation_type, donation_date);`

**After index:** Estimated cost dropped to 9.81, execution time ~0.055 ms (43% faster). The planner cost halved because the composite index allows PostgreSQL to narrow the scan to matching rows directly.

*Note:* With only 25 rows, the absolute time difference is small. At production scale (tens of thousands of donations), the sequential scan would degrade linearly while the B-tree index maintains O(log n) lookup, making this optimisation critical.

### Test Case 2: Attendance count per member

**Before index:** Hash Join with sequential scans on both `attendance` and `members`. Execution time ~0.124 ms.

**Index added:** `CREATE INDEX idx_attendance_member ON attendance(member_id);`

**After index:** Execution time ~0.083 ms (33% improvement). The index enables an index-only scan when the query only needs `member_id` from `attendance`.

### Test Case 3: Complex engagement query (Query 9)

The execution plan for the multi-CTE engagement query shows:
- PostgreSQL materialises each CTE as a HashAggregate (in-memory hash table)
- The main query uses Nested Loop Left Joins to combine the three scores
- The `idx_members_status` index is used to filter active members efficiently
- Total execution: ~0.263 ms

## How to run

```bash
# Seed data (run after schema.sql from Portfolio 1)
psql -d shepherd_db -f seed-data.sql

# Run queries
psql -d shepherd_db -f queries.sql

# Run optimisation analysis with EXPLAIN ANALYZE
psql -d shepherd_db -f optimisation-analysis.sql
```
