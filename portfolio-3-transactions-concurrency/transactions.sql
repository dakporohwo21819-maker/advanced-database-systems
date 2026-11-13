-- =============================================================================
-- Shepherd App â Portfolio 3: Transactions and Concurrency
-- Demonstrates COMMIT, ROLLBACK, SAVEPOINT, isolation, and concurrency control
-- =============================================================================

-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- SCENARIO 1: Successful donation recording (COMMIT)
-- A member gives a tithe and their pledge fulfilment is updated atomically.
-- Both changes succeed, so the transaction commits.
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

BEGIN;

-- Step 1: Record the donation
INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES (1, 1, 50000.00, 'NGN', 'building_fund', 'bank_transfer', '2026-11-01', 2)
RETURNING donation_id, amount, donation_type;

-- Step 2: Update the pledge fulfilment for Emeka's Building Fund pledge
UPDATE pledges
SET    amount_fulfilled = amount_fulfilled + 50000.00,
       status = CASE
                    WHEN amount_fulfilled + 50000.00 >= amount_pledged THEN 'fulfilled'
                    ELSE status
                END
WHERE  member_id = 1 AND campaign = 'Building Fund 2026'
RETURNING pledge_id, amount_pledged, amount_fulfilled, status;

COMMIT;

-- Verify the result
SELECT 'SCENARIO 1 RESULT: Donation + pledge update committed' AS status;
SELECT p.pledge_id, p.amount_pledged, p.amount_fulfilled,
       p.amount_pledged - p.amount_fulfilled AS remaining, p.status
FROM   pledges p
WHERE  p.member_id = 1 AND p.campaign = 'Building Fund 2026';


-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- SCENARIO 2: Failed transaction (ROLLBACK)
-- An attempt to record a donation with an invalid amount triggers rollback.
-- Neither the donation nor the pledge update persists.
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- First, count donations before
SELECT COUNT(*) AS donations_before FROM donations;

BEGIN;

-- Try to insert a negative donation (violates CHECK constraint)
INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES (1, 3, -5000.00, 'NGN', 'tithe', 'cash', '2026-11-01', 2);

-- This line will not execute because the CHECK constraint fails
-- PostgreSQL auto-aborts the transaction on error

ROLLBACK;

-- Verify nothing changed
SELECT 'SCENARIO 2 RESULT: Transaction rolled back â no changes persisted' AS status;
SELECT COUNT(*) AS donations_after FROM donations;


-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- SCENARIO 3: Partial rollback with SAVEPOINT
-- Recording multiple donations in one transaction; one fails but others persist.
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

BEGIN;

-- Donation 1: succeeds
INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES (1, 4, 10000.00, 'NGN', 'offering', 'cash', '2026-11-03', 2);

SAVEPOINT after_donation_1;

-- Donation 2: attempt with non-existent member (FK violation will be caught)
-- We wrap this in a savepoint to recover
SAVEPOINT before_donation_2;

INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES (1, 9999, 5000.00, 'NGN', 'offering', 'cash', '2026-11-03', 2);

-- If the above fails, rollback to savepoint
ROLLBACK TO SAVEPOINT before_donation_2;

-- Donation 3: succeeds
INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES (1, 5, 15000.00, 'NGN', 'offering', 'mobile_money', '2026-11-03', 2);

COMMIT;

SELECT 'SCENARIO 3 RESULT: Donations 1 and 3 committed, Donation 2 rolled back via SAVEPOINT' AS status;

-- Verify: should see the two new donations for Adaeze (member 4) and Chukwudi (member 5)
SELECT donation_id, member_id, amount, donation_type, donation_date
FROM   donations
WHERE  donation_date = '2026-11-03'
ORDER  BY donation_id;


-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- SCENARIO 4: Isolation Level Demonstration (READ COMMITTED vs SERIALIZABLE)
-- Shows how different isolation levels handle concurrent reads.
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

-- 4a. READ COMMITTED (PostgreSQL default)
-- Each statement in the transaction sees the latest committed data.
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT 'SCENARIO 4a: READ COMMITTED isolation' AS status;

-- Read 1: See current total
SELECT SUM(amount) AS total_donations_rc_read1 FROM donations WHERE church_id = 1;

-- Simulate: another session commits a new donation between our two reads
-- (In a real concurrent scenario, this would be in Session B)
INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES (1, 6, 7500.00, 'NGN', 'offering', 'cash', '2026-11-05', 2);

-- Read 2: In READ COMMITTED, this sees the newly committed row
SELECT SUM(amount) AS total_donations_rc_read2 FROM donations WHERE church_id = 1;

COMMIT;


-- 4b. SERIALIZABLE (strictest isolation)
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT 'SCENARIO 4b: SERIALIZABLE isolation' AS status;

-- Read 1
SELECT SUM(amount) AS total_donations_ser_read1 FROM donations WHERE church_id = 1;

-- Even if another session inserts data, SERIALIZABLE ensures this transaction
-- sees a consistent snapshot from the start.
-- Read 2 will return the SAME result as Read 1 within this transaction.
SELECT SUM(amount) AS total_donations_ser_read2 FROM donations WHERE church_id = 1;

COMMIT;


-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
-- SCENARIO 5: Demonstrating a concurrency problem and its resolution
-- Lost Update scenario: two sessions try to update the same pledge.
-- âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

SELECT 'SCENARIO 5: Lost Update prevention with SELECT ... FOR UPDATE' AS status;

-- Without locking (the problem):
-- Session A reads pledge (fulfilled = 150000), calculates new = 150000 + 25000 = 175000
-- Session B reads pledge (fulfilled = 150000), calculates new = 150000 + 30000 = 180000
-- Session A writes 175000
-- Session B writes 180000 â Session A's update is LOST

-- With FOR UPDATE locking (the solution):
BEGIN;

-- Lock the row: any other transaction trying to read FOR UPDATE will WAIT
SELECT pledge_id, amount_fulfilled
FROM   pledges
WHERE  member_id = 1 AND campaign = 'Building Fund 2026'
FOR UPDATE;

-- Safe to update: no other transaction can modify this row until we commit
UPDATE pledges
SET    amount_fulfilled = amount_fulfilled + 25000.00
WHERE  member_id = 1 AND campaign = 'Building Fund 2026'
RETURNING pledge_id, amount_fulfilled AS new_fulfilled;

COMMIT;

-- Final state
SELECT 'FINAL STATE after all transaction scenarios:' AS status;
SELECT p.member_id, m.first_name || ' ' || m.last_name AS member,
       p.campaign, p.amount_pledged, p.amount_fulfilled,
       ROUND(100.0 * p.amount_fulfilled / p.amount_pledged, 1) AS pct
FROM   pledges p
JOIN   members m ON p.member_id = m.member_id
WHERE  p.church_id = 1
ORDER  BY p.campaign, p.member_id;
