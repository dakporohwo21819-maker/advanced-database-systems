# Portfolio 1: Database Design and Modelling

## Case Study: Shepherd App

**Organisation:** Shepherd App (developed by Duten Nexa)

**Nature of the system:** Shepherd is a multi-tenant church operations SaaS platform. It helps churches manage their congregation, track attendance, record donations, coordinate groups and departments, schedule events, and send communications to members. The tagline is *"More time for people. Less time chasing information."*

**Users of the database:**
- **Super admins**: platform-level administrators (Duten Nexa team)
- **Pastors**: senior church leaders with full access to their church's data
- **Admins**: church secretaries and office staff who manage day-to-day records
- **Leaders**: department/group heads who manage their unit's membership and attendance
- **Members**: congregation members (may have self-service accounts or be record-only)

**Major data stored:**
- Church profiles (name, denomination, location, contact details)
- Member records (biographical data, membership status, contact information)
- Groups/departments and their membership rosters
- Events and services with attendance tracking
- Financial records (tithes, offerings, pledges, payment methods)
- Communications log (SMS, email, WhatsApp blasts)
- User accounts with role-based access control

**Key database operations:**
- Register a new church and onboard its admin
- Add, update, and deactivate members
- Create groups and assign members to them
- Schedule events and record attendance (manual, QR code, self-check-in)
- Record donations (tithe, offering, seed, pledge) with payment method tracking
- Send targeted or broadcast communications and log delivery
- Generate reports: attendance trends, donation summaries, group growth

---

## Files in this folder

| File | Description |
|---|---|
| `schema.sql` | Full DDL script, creates all 11 tables with keys, constraints, CHECK rules, and indexes |
| `er-diagram.mmd` | Mermaid source for the Entity-Relationship diagram |
| `er-diagram.svg` | Rendered ER diagram (SVG) |
| `er-diagram.png` | Rendered ER diagram (PNG) |
| `normalisation.md` | Normalisation walkthrough (UNF -> 1NF -> 2NF -> 3NF -> BCNF) with compliance summary |

## How to run

```bash
# Assumes PostgreSQL is installed
createdb shepherd_db
psql -d shepherd_db -f schema.sql
```

## ER Diagram

![Shepherd App ER Diagram](er-diagram.png)

## Design notes

- **Multi-tenancy** is handled via a `church_id` foreign key on every entity table, keeping all churches in one schema while ensuring data isolation through application-level filtering.
- **Surrogate keys** (SERIAL) are used throughout to simplify joins and avoid composite-key complexity.
- All tables are in **BCNF**: see `normalisation.md` for the full analysis.
- **CHECK constraints** enforce domain rules (valid roles, statuses, positive donation amounts) at the database level.
- The `members` <-> `users` relationship is optional (1:0..1): not every congregation member needs a login account.
