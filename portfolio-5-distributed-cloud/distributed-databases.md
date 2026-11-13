# Distributed and Cloud Database Concepts â Shepherd App

## 1. Replication

### What is Replication?

Replication copies data across multiple database servers (replicas) so that if one server fails, others can serve requests. It also improves read performance by distributing queries across replicas.

### Replication Strategies

| Strategy | How it works | Trade-off |
|---|---|---|
| **Single-leader (primaryâreplica)** | One node accepts writes; replicas stream changes asynchronously | Simple, but the leader is a single point of failure for writes |
| **Multi-leader** | Multiple nodes accept writes; they synchronise with each other | Better write availability, but conflict resolution is complex |
| **Leaderless** | Any node accepts reads and writes; quorum decides correctness | Highest availability, but requires careful tuning (R + W > N) |

### How Shepherd Would Use Replication

Shepherd operates as a multi-tenant SaaS serving churches across Nigeria (and potentially other African countries). The recommended replication strategy is **single-leader with read replicas**:

```
                    ââââââââââââââââ
                    â   Primary    â
     Writes ââââââââ¶â  (Lagos DC)  â
                    ââââââââ¬ââââââââ
                           â WAL streaming
              ââââââââââââââ¼âââââââââââââ
              â¼            â¼            â¼
       ââââââââââââ ââââââââââââ ââââââââââââ
       â Replica 1â â Replica 2â â Replica 3â
       â (Lagos)  â â (Abuja)  â â (London) â
       ââââââââââââ ââââââââââââ ââââââââââââ
            â²            â²            â²
         Reads        Reads        Reads
       (Lagos       (Northern    (Diaspora
        churches)    churches)    churches)
```

**Why this fits:**

1. **Write volume is moderate.** Churches record donations, attendance, and communications â high-value but not high-velocity data. A single leader handles this comfortably.
2. **Read volume is high during peak hours.** Sunday mornings see simultaneous dashboard loads, attendance lookups, and member searches from hundreds of churches. Read replicas absorb this load.
3. **Geographic distribution.** Replicas in Abuja and London reduce latency for northern Nigerian and diaspora churches respectively.
4. **Failover.** If the Lagos primary fails, a replica can be promoted to primary within seconds using PostgreSQL's `pg_promote()` or a managed service's automatic failover.

### Replication Lag Considerations

With asynchronous replication, there is a brief window (typically < 1 second) where a replica may not reflect the latest write. For Shepherd, this means:

- A donation recorded by a church admin may take a fraction of a second to appear on the dashboard loaded from a replica. This is acceptable.
- For operations requiring strict consistency (e.g., checking pledge fulfilment before recording a donation), the application routes the query to the primary.

## 2. Sharding (Partitioning)

### What is Sharding?

Sharding splits a large dataset across multiple database servers, each holding a subset of the data. This allows horizontal scaling beyond what a single server can store or process.

### Sharding Strategies

| Strategy | How it works | Best for |
|---|---|---|
| **Range-based** | Rows split by key range (e.g., church_id 1â1000 on shard 1) | Sequential access patterns |
| **Hash-based** | A hash function distributes rows evenly | Even distribution, avoiding hotspots |
| **Directory-based** | A lookup table maps each key to its shard | Flexible, but the directory is a bottleneck |

### How Shepherd Would Shard

Shepherd's multi-tenant architecture makes it a natural candidate for **tenant-based sharding** using `church_id` as the shard key:

```
                   âââââââââââââââââââââ
                   â   Application     â
                   â   (Shard Router)  â
                   ââââââââââ¬âââââââââââ
                            â
            âââââââââââââââââ¼ââââââââââââââââ
            â¼               â¼               â¼
     ââââââââââââââ  ââââââââââââââ  ââââââââââââââ
     â  Shard A   â  â  Shard B   â  â  Shard C   â
     â church_id  â  â church_id  â  â church_id  â
     â iash % 3=0 â  â hash % 3=1 â  â hash % 3=2 â
     ââââââââââââââ  ââââââââââââââ  ââââââââââââââ
```

**Why `church_id` is the ideal shard key:**

1. **Tenant isolation.** Every query in Shepherd is scoped to a single church (`WHERE church_id = ?`). Sharding by `church_id` ensures all of a church's data â members, donations, attendance, events â lives on the same shard, eliminating cross-shard joins.
2. **Even distribution.** Hash-based sharding on `church_id` distributes churches evenly, preventing hotspots even if some churches are larger than others (the hash spreads them).
3. **Independent scaling.** As Shepherd onboards more churches, new shards can be added and existing data rebalanced without downtime (using logical replication or Citus's shard rebalancer).

### When Shepherd Would Need Sharding

At the current scale (tens of churches), a single PostgreSQL instance with read replicas is sufficient. Sharding becomes relevant when:

- The database exceeds a single server's storage (hundreds of thousands of churches with years of history)
- Write throughput on the primary saturates (unlikely for Shepherd's workload, but possible at massive scale)
- Regulatory requirements demand data residency (Nigerian church data on Nigerian servers, UK church data on UK servers)

## 3. The CAP Theorem

### Statement

The CAP theorem (Brewer, 2000) states that a distributed system can guarantee at most **two** of the following three properties simultaneously:

- **Consistency (C):** Every read receives the most recent write or an error.
- **Availability (A):** Every request receives a non-error response (though it may not reflect the most recent write).
- **Partition tolerance (P):** The system continues to operate despite network partitions between nodes.

Since network partitions are unavoidable in distributed systems, the practical choice is between **CP** (consistency + partition tolerance) and **AP** (availability + partition tolerance).

### Shepherd's CAP Position

| Data type | CAP choice | Rationale |
|---|---|---|
| **Donations and pledges** | CP | Financial data must be consistent. A brief unavailability during a network partition is preferable to recording a duplicate or lost donation. |
| **Attendance records** | AP | During a live service, check-ins must not fail. A brief inconsistency (a check-in visible on one replica but not yet on another) is acceptable. |
| **Member profiles** | CP | Contact information and membership status must be authoritative. |
| **Dashboard aggregates** | AP | Cached summaries can be slightly stale without business impact. |
| **Session tokens (Redis)** | AP | A user should not be logged out during a partition. Stale session data is better than no session. |

### Practical Implementation

In PostgreSQL, Shepherd achieves this by:

- **Synchronous replication** for critical tables (donations, pledges) â the primary waits for at least one replica to confirm the write before acknowledging it to the application (CP behaviour).
- **Asynchronous replication** for non-critical tables (attendance, communications) â the primary acknowledges immediately (AP behaviour, higher throughput).

```sql
-- PostgreSQL: per-transaction synchronous commit control
-- For donations (CP â must be consistent)
SET LOCAL synchronous_commit = 'on';
INSERT INTO donations (...) VALUES (...);

-- For attendance (AP â prioritise availability)
SET LOCAL synchronous_commit = 'local';
INSERT INTO attendance (...) VALUES (...);
```

## 4. Cloud Database Deployment

### Recommended Architecture: AWS

```
âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
â                        AWS Cloud (af-south-1, Lagos)                â
â                                                                     â
â  ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ   â
â  â                     VPC (10.0.0.0/16)                        â   â
â  â                                                              â   â
â  â  âââââââââââââââ    ââââââââââââââââââââââââââââââââââââ     â   â
â  â  â  ELB / ALB  âââââ¶â  ECS Fargate (Shepherd API)      â     â   â
â  â  âââââââââââââââ    â  - Node.js containers             â     â   â
â  â                     â  - Auto-scales 2â10 tasks          â     â   â
â  â                     ââââââââââââââââ¬ââââââââââââââââââââ     â   â
â  â                                    â                         â   â
â  â                     ââââââââââââââââ¼ââââââââââââââââââââ     â   â
â  â                     â  Amazon RDS for PostgreSQL        â     â   â
â  â                     â  (Multi-AZ, db.r6g.large)         â     â   â
â  â                     â  - Primary in AZ-a                â     â   â
â  â                     â  - Standby in AZ-b (sync)         â     â   â
â  â                     â  - Read replica in AZ-c           â     â   â
â  â                     â  - Automated backups (7-day)       â     â   â
â  â                     â  - Point-in-time recovery          â     â   â
â  â                     ââââââââââââââââââââââââââââââââââââ     â   â
â  â                                                              â   â
â  â  ââââââââââââââââââââââââ  ââââââââââââââââââââââââââââââ   â   â
â  â  â  ElastiCache (Redis) â  â  S3 (backups, media)       â   â   â
â  â  â  - Sessions           â  â  - Church logos, reports    â   â   â
â  â  â  - Dashboard cache    â  â  - Encrypted at rest        â   â   â
â  â  â  - Attendance counter â  â  - Cross-region replication â   â   â
â  â  ââââââââââââââââââââââââ  ââââââââââââââââââââââââââââââ   â   â
â  â                                                              â   â
â  ââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ   â
â                                                                     â
â  ââââââââââââââââââââââââââââ  ââââââââââââââââââââââââââââââââââ  â
â  â  CloudWatch Monitoring   â  â  AWS Secrets Manager            â  â
â  â  - DB metrics, alarms    â  â  - DB credentials               â  â
â  â  - Replication lag alert â  â  - API keys                     â  â
â  ââââââââââââââââââââââââââââ  ââââââââââââââââââââââââââââââââââ  â
âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
```

### Why AWS with af-south-1 (Cape Town)?

1. **Closest African region.** AWS's Cape Town region (af-south-1) provides the lowest latency for Nigerian users among major cloud providers. (Lagos edge locations further reduce latency for static content.)
2. **Managed PostgreSQL (RDS).** Eliminates operational overhead: automated patching, backups, failover, and monitoring.
3. **Multi-AZ deployment.** The standby replica in a second availability zone provides automatic failover with < 60 seconds of downtime.
4. **Cost-effective scaling.** Shepherd starts with a single db.r6g.large instance (~$200/month) and adds read replicas only when Sunday-morning load demands it.

### Alternative: Google Cloud SQL

Google Cloud's Johannesburg region (africa-south1) offers a comparable managed PostgreSQL service. The architecture would be identical, substituting Cloud SQL for RDS, Memorystore for ElastiCache, and Cloud Run for ECS Fargate.

### Data Residency and Compliance

For churches subject to Nigeria's Data Protection Regulation (NDPR, 2019):

- Primary data resides on African servers (af-south-1)
- Backups replicated to a second African AZ, not to other continents
- Encryption at rest (AES-256) and in transit (TLS 1.3)
- Database audit logging enabled for all data-access events
- IAM policies enforce least-privilege access

## 5. Comparison: Managed vs Self-Hosted

| Aspect | Managed (RDS/Cloud SQL) | Self-hosted (EC2 + PostgreSQL) |
|---|---|---|
| **Setup time** | Minutes | Hours to days |
| **Patching** | Automatic | Manual, requires maintenance windows |
| **Backups** | Built-in, point-in-time recovery | Manual scripting (pg_dump, WAL archiving) |
| **Failover** | Automatic (Multi-AZ) | Manual or requires tools like Patroni |
| **Cost** | Higher per-instance cost, lower operational cost | Lower per-instance cost, higher staffing cost |
| **Customisation** | Limited (no OS access, restricted extensions) | Full control |
| **Best for Shepherd** | **Yes** â small team, SaaS product, needs reliability over customisation | Only if specific PostgreSQL extensions are unavailable on RDS |

## 6. Disaster Recovery Plan

| Component | RPO (data loss tolerance) | RTO (downtime tolerance) | Strategy |
|---|---|---|---|
| PostgreSQL (donations, members) | 0 (zero data loss) | < 60 seconds | Multi-AZ synchronous standby + automated failover |
| PostgreSQL (attendance, comms) | < 5 minutes | < 5 minutes | Asynchronous read replica promotion |
| Redis (sessions, cache) | Tolerable (rebuilt on restart) | < 30 seconds | ElastiCache Multi-AZ with automatic failover |
| Media files (S3) | 0 | 0 | S3 cross-region replication, 99.999999999% durability |
