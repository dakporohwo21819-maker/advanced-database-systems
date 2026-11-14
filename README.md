# Advanced Database Systems: Individual Practical Portfolio

**Module:** MIT 8103, Advanced Database Systems
**Student:** David Akporohwo
**Case Study:** Shepherd App (Church Operations SaaS by Duten Nexa)
**Database:** PostgreSQL 16

---

## About Shepherd App

Shepherd is a multi-tenant SaaS platform that manages church operations: member management, event scheduling, attendance tracking, donations, pledge management, group coordination, and communications. Built by Duten Nexa, it serves multiple churches with tenant isolation via `church_id`.

## Portfolio Components

| # | Portfolio | Marks | Description |
|---|---|---|---|
| 1 | [Database Design & Normalisation](portfolio-1-database-design/) | 7 | 11-table schema, ER diagram, UNF â BCNF analysis |
| 2 | [Query Techniques & Optimisation](portfolio-2-query-optimisation/) | 7 | 10 SQL queries (JOINs, CTEs, window functions), EXPLAIN ANALYZE |
| 3 | [Transactions & Concurrency](portfolio-3-transactions-concurrency/) | 7 | COMMIT, ROLLBACK, SAVEPOINT, isolation levels, row locking |
| 4 | [NoSQL & Advanced Data Models](portfolio-4-nosql/) | 7 | MongoDB, Redis, Neo4j implementations for Shepherd |
| 5 | [Distributed & Cloud Databases](portfolio-5-distributed-cloud/) | 6 | Replication, sharding, CAP theorem, AWS architecture |
| - | Final Documentation & Reflection | 6 | LMS submission, technical reflection, AI-use declaration |

**Total: 40 marks**

## Quick Start

\`\`\`bash
# 1. Create database and run schema
createdb shepherd_db
psql -d shepherd_db -f portfolio-1-database-design/schema.sql

# 2. Load test data
psql -d shepherd_db -f portfolio-2-query-optimisation/seed-data.sql

# 3. Run all SQL portfolios
psql -d shepherd_db -f portfolio-2-query-optimisation/queries.sql
psql -d shepherd_db -f portfolio-2-query-optimisation/optimisation-analysis.sql
psql -d shepherd_db -f portfolio-3-transactions-concurrency/transactions.sql
\`\`\`

## Documentation

See [Akporohwo_David_301921819_FinalDocumentation.md](Akporohwo_David_301921819_FinalDocumentation.md) for the full LMS submission document, including technical reflection, AI-use declaration, and repository structure.

---

*MIT 8103 | Miva Open University | November 2026*
