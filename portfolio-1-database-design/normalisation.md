# Normalisation Analysis â Shepherd App Database

## Overview

This document demonstrates that the Shepherd App relational schema satisfies Third Normal Form (3NF) and, where applicable, Boyce-Codd Normal Form (BCNF). The analysis walks through each normal form using the `donations` table as a detailed example before confirming compliance across all tables.

---

## Worked Example: `donations` table

### Unnormalised (UNF) starting point

Imagine a flat spreadsheet a church might keep:

| DonationID | ChurchName | ChurchCity | MemberName | MemberPhone | Amount | Type | PaymentMethod | Date | RecordedByName |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Grace Chapel | Lagos | Adaeze Obi | 0801... | 5000 | tithe | cash | 2026-09-01 | Pastor Emeka |

Problems: church details repeat per row, member details repeat per row, recorder's name is denormalised.

### First Normal Form (1NF)

**Rule:** every column holds atomic (single) values; every row is uniquely identifiable.

The flat table already has atomic columns and a primary key (DonationID), so 1NF is satisfied. However, redundancy remains.

### Second Normal Form (2NF)

**Rule:** no non-key attribute depends on only part of a composite key.

With a single-column PK (`donation_id`), partial dependency is structurally impossible. 2NF is satisfied.

To remove redundancy, we extract the repeating groups into their own tables:

- `churches` (church_id PK, name, city, ...)
- `members` (member_id PK, church_id FK, first_name, last_name, phone, ...)
- `users` (user_id PK, first_name, last_name, ...) â for the "recorded by" person
- `donations` (donation_id PK, church_id FK, member_id FK, amount, donation_type, payment_method, donation_date, recorded_by FK)

### Third Normal Form (3NF)

**Rule:** no non-key attribute depends on another non-key attribute (no transitive dependencies).

In the final `donations` table:

- `amount`, `donation_type`, `payment_method`, `donation_date`, `notes`, `reference_no` each depend directly on `donation_id`.
- `church_id`, `member_id`, `recorded_by` are foreign keys pointing to their own tables; no church name or member name is stored in `donations`.

There is no transitive dependency. **3NF is satisfied.**

### BCNF check

**Rule:** for every non-trivial functional dependency X â Y, X must be a superkey.

The only determinant in `donations` is `donation_id` (the PK), which is trivially a superkey. **BCNF is satisfied.**

---

## Compliance Summary (all tables)

| Table | PK | Partial deps? | Transitive deps? | NF achieved |
|---|---|---|---|---|
| churches | church_id | None (single PK) | None | BCNF |
| users | user_id | None | None â church details via FK | BCNF |
| members | member_id | None | None â church/user via FK | BCNF |
| groups | group_id | None | None â church/leader via FK | BCNF |
| group_members | group_member_id | None | None â references only FKs | BCNF |
| events | event_id | None | None â church/creator via FK | BCNF |
| attendance | attendance_id | None | None â event/member via FK | BCNF |
| donations | donation_id | None | None â all entities via FK | BCNF |
| communications | communication_id | None | None | BCNF |
| communication_recipients | recipient_id | None | None | BCNF |
| pledges | pledge_id | None | None | BCNF |

### Key design decisions

1. **Surrogate keys everywhere:** every table uses a single auto-increment PK, eliminating partial-dependency risk by design.
2. **No derived data stored:** totals (e.g. total donations per member) are computed via queries, not stored columns, avoiding update anomalies.
3. **CHECK constraints enforce domain integrity:** role values, status values, and positive-amount rules are enforced at the schema level.
4. **Multi-tenant isolation via `church_id` FK:** every entity traces back to a church, supporting data isolation without schema duplication.
