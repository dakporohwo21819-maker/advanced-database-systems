# Portfolio 3: Transactions and Concurrency

## Overview

This portfolio demonstrates transaction management, isolation levels, and concurrency control in PostgreSQL, applied to the **Shepherd App** church operations database.

## Files

| File | Description |
|---|---|
| `transactions.sql` | Five transaction scenarios covering COMMIT, ROLLBACK, SAVEPOINT, isolation levels, and row locking |
| `transaction-output.txt` | Captured output from running all scenarios |

## Scenarios

### Scenario 1: Successful COMMIT

**Business case:** A member makes a building fund donation, and their pledge fulfilment is updated atomically.

Both operations (INSERT donation + UPDATE pledge) succeed, so the transaction commits. If either had failed, neither change would persist, ensuring data consistency between the `donations` and `pledges` tables.

**Result:** Emeka's pledge fulfilment went from 100,000 to 150,000 NGN.

### Scenario 2: ROLLBACK on constraint violation

**Business case:** An attempt to record a negative donation amount.

The `CHECK (amount > 0)` constraint on the `donations` table rejects the insert. PostgreSQL automatically aborts the transaction. The explicit ROLLBACK confirms no partial changes persist.

**Result:** Donation count remained at 26 (unchanged).

### Scenario 3: Partial rollback with SAVEPOINT

**Business case:** Recording multiple donations in a batch; one references a non-existent member.

Using SAVEPOINTs, the failed insert (member_id 9999, FK violation) is rolled back to the savepoint, while the two valid donations commit successfully.

**Result:** Donations for members 4 and 5 on 2026-11-03 were saved; the invalid donation was discarded.

### Scenario 4: Isolation Level Comparison

**4a. READ COMMITTED (PostgreSQL default):**
- Read 1 shows total donations = 494,000 NGN
- A new 7,500 NGN donation is inserted and committed
- Read 2 sees the new total = 501,500 NGN (sees committed changes between statements)

**4b. SERIALIZABLE:**
- Both Read 1 and Read 2 return the same value (501,500 NGN)
- The transaction operates on a consistent snapshot from its start, regardless of concurrent changes

This demonstrates the key difference: READ COMMITTED allows non-repeatable reads (different results for the same query within one transaction), while SERIALIZABLE prevents them.

### Scenario 5: Lost Update Prevention (SELECT ... FOR UPDATE)

**The problem:** Two concurrent sessions read a pledge's fulfilled amount (150,000), each adds their own contribution (25,000 and 30,000), and the second write overwrites the first. The expected result (205,000) becomes 180,000, and 25,000 is silently lost.

**The solution:** `SELECT ... FOR UPDATE` acquires a row-level exclusive lock. The second session must wait until the first commits, then reads the updated value (175,000) before adding its own contribution.

**Result:** Emeka's pledge fulfilment correctly updated to 175,000 NGN.

## How to run

```bash
# Ensure schema.sql and seed-data.sql have been run first
psql -d shepherd_db -f transactions.sql
```
