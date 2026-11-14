# Portfolio 5: Distributed and Cloud Database Exercise

## Overview

This portfolio applies distributed database theory to the **Shepherd App** SaaS platform, covering replication, sharding, the CAP theorem, and a production-ready cloud deployment architecture.

## Files

| File | Description |
|---|---|
| `distributed-databases.md` | Full discussion: replication strategies, sharding by church_id, CAP analysis per data type, cloud architecture, disaster recovery |
| `cloud-architecture.mmd` | Mermaid source for the cloud deployment diagram |
| `cloud-architecture.svg` | Rendered architecture diagram (SVG) |
| `cloud-architecture.png` | Rendered architecture diagram (PNG) |

## Key Concepts Demonstrated

### Replication

Single-leader with read replicas across Lagos, Abuja, and London. PostgreSQL WAL streaming provides sub-second replication lag. The primary handles writes; replicas absorb read-heavy Sunday-morning dashboard loads.

### Sharding

Tenant-based sharding using `church_id` as the shard key. Because every Shepherd query is scoped to a single church, all of a church's data (members, donations, attendance) lives on the same shard, eliminating cross-shard joins entirely.

### CAP Theorem

Shepherd adopts a **mixed CP/AP strategy** based on data criticality:

- **CP (consistency preferred):** Donations, pledges, member profiles, financial and identity data must be authoritative, so synchronous replication is used.
- **AP (availability preferred):** Attendance check-ins, dashboard caches, session tokens, brief inconsistency is acceptable; availability during live services is not negotiable.

### Cloud Deployment

AWS-based architecture using af-south-1 (Cape Town) as the primary region:

- **Amazon RDS for PostgreSQL**: Multi-AZ with automated failover
- **ElastiCache for Redis**: Session management and caching
- **ECS Fargate**: Containerised API with auto-scaling
- **S3**: Media storage with cross-region replication
- **CloudWatch**: Monitoring and alerting

### Disaster Recovery

| Data tier | RPO | RTO | Method |
|---|---|---|---|
| Financial data | Zero | < 60s | Synchronous Multi-AZ standby |
| Operational data | < 5 min | < 5 min | Async replica promotion |
| Cache (Redis) | Tolerable | < 30s | ElastiCache Multi-AZ |
| Media (S3) | Zero | Zero | Cross-region replication |
