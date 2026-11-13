-- =============================================================================
-- Shepherd App â Church Operations SaaS
-- MIT 8103 Advanced Database Systems â Portfolio 1: Database Design & Modelling
-- DDL Script (PostgreSQL 16)
-- =============================================================================

-- 1. CHURCHES (tenant table â every other entity belongs to a church)
CREATE TABLE churches (
    church_id       SERIAL PRIMARY KEY,
    name            VARCHAR(200)  NOT NULL,
    denomination    VARCHAR(100),
    address         TEXT,
    city            VARCHAR(100),
    country         VARCHAR(60)   NOT NULL DEFAULT 'Nigeria',
    phone           VARCHAR(20),
    email           VARCHAR(150)  UNIQUE,
    website         VARCHAR(255),
    founded_date    DATE,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 2. USERS (login accounts â pastors, admins, volunteers)
CREATE TABLE users (
    user_id         SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    first_name      VARCHAR(80)   NOT NULL,
    last_name       VARCHAR(80)   NOT NULL,
    email           VARCHAR(150)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255)  NOT NULL,
    role            VARCHAR(30)   NOT NULL DEFAULT 'member'
                        CHECK (role IN ('super_admin','pastor','admin','leader','member')),
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE,
    last_login      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 3. MEMBERS (church congregation members â may or may not have a user account)
CREATE TABLE members (
    member_id       SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    user_id         INT           REFERENCES users(user_id),
    first_name      VARCHAR(80)   NOT NULL,
    last_name       VARCHAR(80)   NOT NULL,
    gender          VARCHAR(10)   CHECK (gender IN ('Male','Female','Other')),
    date_of_birth   DATE,
    phone           VARCHAR(20),
    email           VARCHAR(150),
    address         TEXT,
    member_since    DATE          NOT NULL DEFAULT CURRENT_DATE,
    status          VARCHAR(20)   NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active','inactive','transferred','deceased')),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    UNIQUE (church_id, email)
);

-- 4. GROUPS (departments, cells, units within a church)
CREATE TABLE groups (
    group_id        SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    name            VARCHAR(120)  NOT NULL,
    description     TEXT,
    group_type      VARCHAR(30)   NOT NULL DEFAULT 'department'
                        CHECK (group_type IN ('department','cell','unit','choir','youth','children','other')),
    leader_id       INT           REFERENCES members(member_id),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 5. GROUP_MEMBERS (many-to-many: members â groups)
CREATE TABLE group_members (
    group_member_id SERIAL PRIMARY KEY,
    group_id        INT           NOT NULL REFERENCES groups(group_id),
    member_id       INT           NOT NULL REFERENCES members(member_id),
    role_in_group   VARCHAR(30)   DEFAULT 'member',
    joined_at       DATE          NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (group_id, member_id)
);

-- 6. EVENTS (services, meetings, programmes)
CREATE TABLE events (
    event_id        SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    title           VARCHAR(200)  NOT NULL,
    description     TEXT,
    event_type      VARCHAR(30)   NOT NULL DEFAULT 'service'
                        CHECK (event_type IN ('service','meeting','conference','outreach','prayer','youth','other')),
    location        VARCHAR(200),
    start_time      TIMESTAMPTZ   NOT NULL,
    end_time        TIMESTAMPTZ,
    is_recurring    BOOLEAN       NOT NULL DEFAULT FALSE,
    created_by      INT           REFERENCES users(user_id),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 7. ATTENDANCE (who attended which event)
CREATE TABLE attendance (
    attendance_id   SERIAL PRIMARY KEY,
    event_id        INT           NOT NULL REFERENCES events(event_id),
    member_id       INT           NOT NULL REFERENCES members(member_id),
    check_in_time   TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    check_in_method VARCHAR(20)   DEFAULT 'manual'
                        CHECK (check_in_method IN ('manual','qr_code','self_checkin')),
    UNIQUE (event_id, member_id)
);

-- 8. DONATIONS (tithes, offerings, pledges)
CREATE TABLE donations (
    donation_id     SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    member_id       INT           REFERENCES members(member_id),  -- NULL = anonymous
    amount          NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    currency        VARCHAR(3)    NOT NULL DEFAULT 'NGN',
    donation_type   VARCHAR(30)   NOT NULL DEFAULT 'offering'
                        CHECK (donation_type IN ('tithe','offering','seed','pledge','building_fund','special','other')),
    payment_method  VARCHAR(30)   DEFAULT 'cash'
                        CHECK (payment_method IN ('cash','bank_transfer','card','mobile_money','online')),
    reference_no    VARCHAR(60),
    donation_date   DATE          NOT NULL DEFAULT CURRENT_DATE,
    notes           TEXT,
    recorded_by     INT           REFERENCES users(user_id),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 9. COMMUNICATIONS (messages, announcements, SMS/email blasts)
CREATE TABLE communications (
    communication_id SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    subject         VARCHAR(200)  NOT NULL,
    body            TEXT          NOT NULL,
    channel         VARCHAR(20)   NOT NULL DEFAULT 'sms'
                        CHECK (channel IN ('sms','email','push','whatsapp')),
    target_type     VARCHAR(20)   NOT NULL DEFAULT 'all'
                        CHECK (target_type IN ('all','group','individual')),
    target_group_id INT           REFERENCES groups(group_id),
    sent_by         INT           REFERENCES users(user_id),
    sent_at         TIMESTAMPTZ,
    status          VARCHAR(20)   NOT NULL DEFAULT 'draft'
                        CHECK (status IN ('draft','scheduled','sent','failed')),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 10. COMMUNICATION_RECIPIENTS (delivery log per member)
CREATE TABLE communication_recipients (
    recipient_id     SERIAL PRIMARY KEY,
    communication_id INT          NOT NULL REFERENCES communications(communication_id),
    member_id        INT          NOT NULL REFERENCES members(member_id),
    delivered        BOOLEAN      DEFAULT FALSE,
    delivered_at     TIMESTAMPTZ,
    UNIQUE (communication_id, member_id)
);

-- 11. PLEDGES (future commitments tracked separately)
CREATE TABLE pledges (
    pledge_id       SERIAL PRIMARY KEY,
    church_id       INT           NOT NULL REFERENCES churches(church_id),
    member_id       INT           NOT NULL REFERENCES members(member_id),
    campaign        VARCHAR(120)  NOT NULL,
    amount_pledged  NUMERIC(12,2) NOT NULL CHECK (amount_pledged > 0),
    amount_fulfilled NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (amount_fulfilled >= 0),
    currency        VARCHAR(3)    NOT NULL DEFAULT 'NGN',
    due_date        DATE,
    status          VARCHAR(20)   NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active','fulfilled','overdue','cancelled')),
    created_at      TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Indexes for common query patterns
CREATE INDEX idx_members_church      ON members(church_id);
CREATE INDEX idx_members_status      ON members(status);
CREATE INDEX idx_events_church_date  ON events(church_id, start_time);
CREATE INDEX idx_attendance_event    ON attendance(event_id);
CREATE INDEX idx_donations_church    ON donations(church_id, donation_date);
CREATE INDEX idx_donations_member    ON donations(member_id);
CREATE INDEX idx_groups_church       ON groups(church_id);
CREATE INDEX idx_pledges_member      ON pledges(member_id);
