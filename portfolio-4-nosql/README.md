# Portfolio 4 â NoSQL and Advanced Data Models

## Overview

This portfolio re-models the **Shepherd App** case study using three different NoSQL paradigms, explains why each suits specific aspects of the system, and compares them to the relational model from Portfolio 1.

## Files

| File | Description |
|---|---|
| `mongodb-document-model.js` | Full MongoDB implementation: collections, documents, queries, aggregation pipeline, and indexes (runnable in mongosh) |
| `redis-key-value.md` | Redis key-value model for sessions, live counters, notification queues, and dashboard caching |
| `graph-model.md` | Neo4j graph model for member relationships, mentorship chains, and group co-membership |

## NoSQL Model Comparison

| Aspect | MongoDB (Document) | Redis (Key-Value) | Neo4j (Graph) |
|---|---|---|---|
| **Data shape** | Nested JSON documents | Simple key â value pairs | Nodes + edges |
| **Shepherd use case** | Member profiles, events with embedded attendance, donations | Session tokens, live attendance counters, dashboard cache | Mentorship chains, group co-membership, family links |
| **Strength** | Flexible schema, embedded related data, powerful aggregation | Sub-millisecond reads, atomic counters, TTL expiry | Relationship traversal, variable-depth queries |
| **Trade-off** | No multi-document ACID by default (use transactions if needed) | Volatile (in-memory), limited query capability | Poor for bulk aggregation, requires separate store for transactional data |

## Why Document Store (MongoDB) is the Primary NoSQL Choice for Shepherd

1. **Flexible member profiles:** Different churches may track different custom fields (cell group names, regional zones, ministry-specific data). MongoDB's schema-less design accommodates this without ALTER TABLE migrations.

2. **Embedded attendance:** An event document with an embedded attendees array provides a single read to display the full attendance register, compared to a JOIN across three tables in PostgreSQL.

3. **Natural fit for the API layer:** Shepherd's frontend communicates via JSON APIs. MongoDB documents map directly to API responses without ORM translation overhead.

4. **Aggregation pipeline:** MongoDB's built-in `$group`, `$match`, `$sort` pipeline operators can produce donation summaries, attendance trends, and engagement scores without moving data to a separate analytics tool.

5. **Multi-tenancy:** Adding `church_id` to every document and indexing it provides efficient tenant isolation, mirroring the relational design's approach.

## Design Decisions

**Embedding vs referencing:**
- **Embedded:** Groups within churches (small, bounded, always displayed together), attendance within events (bounded per event), group memberships within members (small array).
- **Referenced:** Members reference `church_id` rather than embedding the full church document (shared by many members, changes independently).

**Capped arrays:** Member documents embed only the last 5 attendance records (`recent_attendance`). Full attendance history lives in the `events` collection. This keeps member documents small while providing quick access to recent activity.

## How to run the MongoDB script

```bash
# Start MongoDB (if installed locally)
mongod --dbpath /data/db

# Run the script
mongosh shepherd_nosql < mongodb-document-model.js
```
