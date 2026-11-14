# MIT 8103: Advanced Database Systems
# Continuous Assessment: Individual Practical Database Portfolio

---

**Student Name:** David Akporohwo
**Student Email:** d.akporohwo21819@miva.edu.ng
**Programme:** Master of Information Technology (MIT)
**Module:** MIT 8103, Advanced Database Systems
**Institution:** Miva Open University
**Date:** November 2026

---

## 1. Introduction

This portfolio presents my practical work for the MIT 8103 Advanced Database Systems continuous assessment. The case study is **Shepherd App**, a church operations SaaS platform I developed at Duten Nexa, applying the database design principles, query optimisation techniques, transaction management strategies, and distributed systems concepts I learnt throughout this course.

Shepherd App manages core church operations (member management, event scheduling, attendance tracking, donation recording, pledge management, group coordination, and communications) for multiple churches as a multi-tenant platform. Each church operates as an independent tenant, isolated by a `church_id` discriminator present across all tables.

**Note on submission email:** This assignment is submitted via my school email (d.akporohwo21819@miva.edu.ng). The Shepherd App project was originally developed under my official work email at Duten Nexa. The academic work presented here was completed under my student identity.

## 2. Portfolio Summary

The portfolio is organised into five components, each addressing a specific learning outcome of the module:

### Portfolio 1: Database Design and Normalisation (7 marks)

Designed a relational schema of 11 tables for Shepherd App, including churches, users, members, groups, events, attendance, donations, pledges, and communications. Each table was analysed for normalisation compliance through UNF -> 1NF -> 2NF -> 3NF -> BCNF, with all tables achieving BCNF. An ER diagram (rendered from Mermaid source) documents the complete data model with all relationships and cardinalities.

**Key decisions:**
- Surrogate keys (SERIAL) throughout to eliminate partial-dependency risk
- CHECK constraints for data integrity (donation amounts > 0, valid status enums)
- Multi-tenant isolation via `church_id` foreign key on all tenant-scoped tables

### Portfolio 2: Query Techniques and Optimisation (7 marks)

Implemented 10 SQL queries of increasing complexity: basic SELECT with JOINs, GROUP BY aggregations, multi-table JOINs, subqueries (standard and correlated), Common Table Expressions, window functions (RANK, running totals), and multi-CTE engagement scoring. Each query was executed against realistic seed data (3 churches, 30 members, 25 donations, 51 attendance records).

Optimisation analysis used EXPLAIN ANALYZE to measure before-and-after performance with targeted indexes, demonstrating measurable improvements (up to 43% cost reduction on donation aggregation queries).

### Portfolio 3: Transactions and Concurrency (7 marks)

Demonstrated five transaction scenarios: successful COMMIT (atomic donation + pledge update), ROLLBACK on constraint violation, partial rollback with SAVEPOINTs, isolation level comparison (READ COMMITTED vs SERIALIZABLE), and lost-update prevention using SELECT ... FOR UPDATE. All scenarios were executed against the live database with output captured.

### Portfolio 4: NoSQL and Advanced Data Models (7 marks)

Re-modelled Shepherd's data using three NoSQL paradigms:
- **MongoDB (document store):** Church and member documents with embedded groups, capped attendance arrays, and an aggregation pipeline for donation analytics
- **Redis (key-value store):** Session management, live attendance counters, notification queues, and dashboard caching
- **Neo4j (graph database):** Member relationships (mentorship/discipleship chains, group co-membership, and family connections) with Cypher queries for variable-depth traversals

Each model includes a justification for why it suits the specific use case, and a comparison with the relational approach.

### Portfolio 5: Distributed and Cloud Database Exercise (6 marks)

Applied distributed database theory to Shepherd's production architecture: single-leader replication with read replicas across Lagos, Abuja, and London; tenant-based sharding using `church_id`; a mixed CP/AP strategy based on data criticality (synchronous replication for financial data, asynchronous for attendance); and a full AWS cloud deployment architecture using RDS PostgreSQL, ElastiCache Redis, ECS Fargate, and S3, deployed in af-south-1 with Multi-AZ failover and a documented disaster recovery plan.

## 3. Technical Reflection

Working through this portfolio reinforced several concepts that directly influenced Shepherd App's architecture:

**Normalisation as a design discipline.** Systematically decomposing the donations table from UNF through BCNF revealed redundancies I might have missed through intuition alone. The exercise confirmed that surrogate keys and single-purpose tables are not over-engineering, they are the minimum viable structure for a multi-tenant system where data integrity cannot be compromised.

**Query optimisation is not optional.** The EXPLAIN ANALYZE exercises showed that even with correct indexes, the planner's choices depend on data distribution. A query that performs well in development (30 members) may behave differently at scale (30,000 members). The habit of profiling queries before deployment, rather than after a performance complaint, is one I have carried into production work.

**Transactions protect business logic, not just data.** The SAVEPOINT scenario (batch donation recording where one entry fails) maps directly to a real Shepherd feature: bulk-importing attendance from a CSV. Without savepoints, a single invalid row would roll back the entire import, forcing the church admin to re-submit. With them, valid rows commit and the admin fixes only the failures.

**NoSQL is a complement, not a replacement.** The MongoDB exercise showed where document stores shine (flexible member profiles, embedded attendance) and where they introduce complexity (multi-document transactions for financial operations). The conclusion (PostgreSQL as the system of record, with Redis for caching and Neo4j for relationship queries) reflects a polyglot persistence strategy that matches each data access pattern to the right engine.

**Cloud architecture decisions are CAP decisions.** Choosing synchronous replication for donations but asynchronous for attendance is not a technical configuration detail, it is a business decision about which failures are acceptable. This framing helps non-technical stakeholders (church leadership) understand why the system behaves the way it does.

## 4. AI-Use Declaration

Portions of this portfolio were developed with the assistance of AI tools (Claude by Anthropic) for code generation, documentation drafting, and technical review. All generated content was reviewed, validated, and adapted to the Shepherd App context. The database schema, seed data, and business logic reflect the actual design decisions made during the development of the Shepherd App platform. SQL queries were executed against a live PostgreSQL instance, and all output was captured from actual database responses.

## 5. Repository Structure

```
Akporohwo_David_301921819/
âââ Akporohwo_David_301921819_FinalDocumentation.md  <- This document
âââ Akporohwo_David_301921819_README.md               <- Repository overview and setup
âââ portfolio-1-database-design/
â   âââ README.md
â   âââ schema.sql                   <- Full DDL (11 tables)
â   âââ er-diagram.mmd              <- Mermaid ER diagram source
â   âââ er-diagram.svg              <- Rendered ER diagram
â   âââ er-diagram.png              <- Rendered ER diagram (PNG)
â   âââ normalisation.md            <- UNF -> BCNF walkthrough
âââ portfolio-2-query-optimisation/
â   âââ README.md
â   âââ seed-data.sql               <- Realistic test data
â   âââ queries.sql                  <- 10 SQL queries
â   âââ optimisation-analysis.sql    <- EXPLAIN ANALYZE tests
â   âââ explain-output.txt           <- Captured query plans
âââ portfolio-3-transactions-concurrency/
â   âââ README.md
â   âââ transactions.sql             <- 5 transaction scenarios
â   âââ transaction-output.txt       <- Captured output
âââ portfolio-4-nosql/
â   âââ README.md
â   âââ mongodb-document-model.js    <- MongoDB implementation
â   âââ redis-key-value.md           <- Redis model documentation
â   âââ graph-model.md              <- Neo4j graph model
âââ portfolio-5-distributed-cloud/
    âââ README.md
    âââ distributed-databases.md     <- Replication, sharding, CAP, cloud
    âââ cloud-architecture.mmd       <- Mermaid diagram source
    âââ cloud-architecture.svg       <- Rendered architecture diagram
    âââ cloud-architecture.png       <- Rendered architecture diagram (PNG)
```

## 6. How to Run

```bash
# Prerequisites: PostgreSQL 16+
# 1. Create the database
createdb shepherd_db

# 2. Run the schema
psql -d shepherd_db -f portfolio-1-database-design/schema.sql

# 3. Seed test data
psql -d shepherd_db -f portfolio-2-query-optimisation/seed-data.sql

# 4. Run queries
psql -d shepherd_db -f portfolio-2-query-optimisation/queries.sql

# 5. Run optimisation analysis
psql -d shepherd_db -f portfolio-2-query-optimisation/optimisation-analysis.sql

# 6. Run transaction scenarios
psql -d shepherd_db -f portfolio-3-transactions-concurrency/transactions.sql

# 7. MongoDB (requires mongosh)
mongosh shepherd_nosql < portfolio-4-nosql/mongodb-document-model.js
```

---

*Submitted by David Akporohwo | Miva Open University | MIT 8103 Advanced Database Systems | November 2026*
