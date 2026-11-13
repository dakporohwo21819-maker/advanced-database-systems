# Redis Key-Value Model â Shepherd App

## Use Case

Redis is used in Shepherd as a **caching and session management layer**, complementing the primary database (PostgreSQL or MongoDB). It handles data that must be accessed with sub-millisecond latency and has a natural expiry.

## Data Model

### 1. User Sessions (String + TTL)

```redis
# Store a session token after login
SET session:usr_001 '{"user_id":"usr_001","church_id":"church_001","role":"pastor","name":"Emeka Okafor"}' EX 3600

# Retrieve session
GET session:usr_001
# â {"user_id":"usr_001","church_id":"church_001","role":"pastor","name":"Emeka Okafor"}

# Check TTL
TTL session:usr_001
# â 3547 (seconds remaining)
```

**Why Redis:** Sessions are read on every authenticated request. A PostgreSQL lookup per request adds unnecessary latency. Redis provides O(1) lookups with automatic expiry.

### 2. Live Attendance Counter (Hash)

```redis
# Track real-time attendance for an ongoing service
HSET attendance:evt_001 total 0 manual 0 qr_code 0 self_checkin 0

# Member checks in via QR code
HINCRBY attendance:evt_001 total 1
HINCRBY attendance:evt_001 qr_code 1

# Member checks in manually
HINCRBY attendance:evt_001 total 1
HINCRBY attendance:evt_001 manual 1

# Dashboard reads current count
HGETALL attendance:evt_001
# â {"total":"12","manual":"7","qr_code":"3","self_checkin":"2"}
```

**Why Redis:** During a live service, the attendance counter is updated by multiple devices simultaneously (phones scanning QR codes, ushers recording manually). Redis Hashes provide atomic increments without locking overhead.

### 3. Recent Notifications Queue (List)

```redis
# Push a notification for a user
LPUSH notifications:usr_001 '{"type":"reminder","message":"Sunday Service starts in 1 hour","time":"2026-09-01T07:00:00Z"}'
LPUSH notifications:usr_001 '{"type":"donation","message":"Your tithe of 50,000 NGN has been recorded","time":"2026-09-01T12:30:00Z"}'

# Retrieve last 5 notifications
LRANGE notifications:usr_001 0 4

# Trim to keep only last 20
LTRIM notifications:usr_001 0 19
```

**Why Redis:** Notification feeds are append-heavy, read-recent, and bounded. Redis Lists with LTRIM give a natural capped queue without table scans.

### 4. Church Dashboard Cache (String + TTL)

```redis
# Cache the dashboard summary (refreshed every 5 minutes)
SET dashboard:church_001 '{"active_members":13,"this_month_donations":319000,"attendance_last_sunday":12,"pending_pledges":3}' EX 300

# Dashboard page reads from cache
GET dashboard:church_001
```

**Why Redis:** Dashboard data involves multiple aggregation queries. Caching the computed result for 5 minutes reduces database load during peak hours (Sunday mornings).

## Architecture Position

```
Client â API Server â Redis (cache/session check)
                    â (cache miss)
               PostgreSQL / MongoDB (primary store)
```

Redis is **not** a replacement for the relational or document database. It sits in front as a read-through cache and session store. Data that must survive a restart lives in PostgreSQL/MongoDB; Redis holds ephemeral or derived data.
