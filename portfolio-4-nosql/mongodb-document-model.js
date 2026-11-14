// =============================================================================
// Shepherd App, Portfolio 4: NoSQL (MongoDB Document Model)
// Run with: mongosh shepherd_nosql < mongodb-document-model.js
// =============================================================================

// Select/create the database
use("shepherd_nosql");

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 1. DOCUMENT MODEL DESIGN
// In MongoDB, we embed related data that is always accessed together,
// and reference data that is shared or accessed independently.
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

// Drop existing collections for a clean run
db.churches.drop();
db.members.drop();
db.events.drop();
db.donations.drop();

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 2. CHURCHES COLLECTION
// Embeds: groups (always displayed with the church)
// References: members, events (too many to embed)
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

db.churches.insertOne({
  _id: "church_001",
  name: "Grace Chapel Lagos",
  denomination: "Pentecostal",
  contact: {
    address: "15 Admiralty Way, Lekki",
    city: "Lagos",
    country: "Nigeria",
    phone: "+234-801-234-5678",
    email: "info@gracechapel.ng",
    website: "https://gracechapel.ng"
  },
  founded_date: ISODate("2010-03-15"),
  // Embedded subdocuments: groups belong tightly to the church
  groups: [
    {
      group_id: "grp_001",
      name: "Choir",
      type: "choir",
      leader: { member_id: "mem_003", name: "Tunde Bakare" },
      member_count: 5
    },
    {
      group_id: "grp_002",
      name: "Youth Ministry",
      type: "youth",
      leader: { member_id: "mem_004", name: "Adaeze Obi" },
      member_count: 5
    },
    {
      group_id: "grp_003",
      name: "Media Unit",
      type: "unit",
      leader: { member_id: "mem_005", name: "Chukwudi Eze" },
      member_count: 3
    },
    {
      group_id: "grp_004",
      name: "Prayer Warriors",
      type: "department",
      leader: { member_id: "mem_006", name: "Folake Adeyemi" },
      member_count: 3
    }
  ],
  stats: {
    total_members: 15,
    active_members: 13,
    last_updated: ISODate("2026-11-01")
  },
  created_at: ISODate("2026-01-15"),
  updated_at: ISODate("2026-11-01")
});

print("[ok] Church document inserted");

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 3. MEMBERS COLLECTION
// Embeds: group memberships (small array, accessed with the member)
// Embeds: recent attendance (capped array for quick access)
// References: church_id (avoids duplicating church data)
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

db.members.insertMany([
  {
    _id: "mem_001",
    church_id: "church_001",
    first_name: "Emeka",
    last_name: "Okafor",
    gender: "Male",
    date_of_birth: ISODate("1980-05-10"),
    contact: {
      phone: "08012345678",
      email: "emeka@gracechapel.ng",
      address: "10 Lekki Phase 1, Lagos"
    },
    role: "pastor",
    status: "active",
    member_since: ISODate("2010-03-15"),
    // Embedded: groups this member belongs to
    groups: [
      { group_id: "grp_004", name: "Prayer Warriors", role: "member", joined: ISODate("2010-04-01") }
    ],
    // Embedded: last 5 attendance records (capped for performance)
    recent_attendance: [
      { event_id: "evt_001", title: "Sunday Service", date: ISODate("2026-09-01"), method: "manual" },
      { event_id: "evt_002", title: "Sunday Service", date: ISODate("2026-09-08"), method: "manual" },
      { event_id: "evt_003", title: "Sunday Service", date: ISODate("2026-09-15"), method: "manual" },
      { event_id: "evt_005", title: "Midweek Prayer", date: ISODate("2026-09-03"), method: "manual" }
    ],
    // Embedded: donation summary (aggregated, not individual records)
    donation_summary: {
      total_given: 100000.00,
      last_donation_date: ISODate("2026-10-06"),
      donation_count: 2
    },
    created_at: ISODate("2026-01-15"),
    updated_at: ISODate("2026-11-01")
  },
  {
    _id: "mem_004",
    church_id: "church_001",
    first_name: "Adaeze",
    last_name: "Obi",
    gender: "Female",
    date_of_birth: ISODate("1995-02-14"),
    contact: {
      phone: "08045678901",
      email: "adaeze.obi@gmail.com"
    },
    role: "member",
    status: "active",
    member_since: ISODate("2016-09-05"),
    groups: [
      { group_id: "grp_001", name: "Choir", role: "member", joined: ISODate("2016-10-01") },
      { group_id: "grp_002", name: "Youth Ministry", role: "leader", joined: ISODate("2016-09-05") }
    ],
    recent_attendance: [
      { event_id: "evt_001", title: "Sunday Service", date: ISODate("2026-09-01"), method: "qr_code" },
      { event_id: "evt_002", title: "Sunday Service", date: ISODate("2026-09-08"), method: "qr_code" },
      { event_id: "evt_003", title: "Sunday Service", date: ISODate("2026-09-15"), method: "qr_code" },
      { event_id: "evt_007", title: "Youth Conference 2026", date: ISODate("2026-10-05"), method: "qr_code" }
    ],
    donation_summary: {
      total_given: 25000.00,
      last_donation_date: ISODate("2026-10-05"),
      donation_count: 2
    },
    created_at: ISODate("2026-09-05"),
    updated_at: ISODate("2026-11-01")
  }
]);

print("[ok] Member documents inserted");

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 4. EVENTS COLLECTION
// Embeds: attendance list (bounded per event, accessed together)
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

db.events.insertOne({
  _id: "evt_001",
  church_id: "church_001",
  title: "Sunday Service",
  type: "service",
  location: "Main Auditorium",
  start_time: ISODate("2026-09-01T08:00:00Z"),
  end_time: ISODate("2026-09-01T11:00:00Z"),
  is_recurring: true,
  created_by: "mem_001",
  attendees: [
    { member_id: "mem_001", name: "Emeka Okafor", check_in: ISODate("2026-09-01T07:50:00Z"), method: "manual" },
    { member_id: "mem_002", name: "Blessing Adekunle", check_in: ISODate("2026-09-01T07:55:00Z"), method: "manual" },
    { member_id: "mem_003", name: "Tunde Bakare", check_in: ISODate("2026-09-01T08:05:00Z"), method: "qr_code" },
    { member_id: "mem_004", name: "Adaeze Obi", check_in: ISODate("2026-09-01T08:00:00Z"), method: "qr_code" },
    { member_id: "mem_005", name: "Chukwudi Eze", check_in: ISODate("2026-09-01T08:10:00Z"), method: "manual" },
    { member_id: "mem_006", name: "Folake Adeyemi", check_in: ISODate("2026-09-01T07:45:00Z"), method: "manual" },
    { member_id: "mem_007", name: "Gbenga Olumide", check_in: ISODate("2026-09-01T08:15:00Z"), method: "manual" },
    { member_id: "mem_008", name: "Halima Bello", check_in: ISODate("2026-09-01T08:20:00Z"), method: "self_checkin" },
    { member_id: "mem_009", name: "Ikenna Nnamdi", check_in: ISODate("2026-09-01T08:00:00Z"), method: "qr_code" },
    { member_id: "mem_010", name: "Jumoke Fashola", check_in: ISODate("2026-09-01T08:05:00Z"), method: "self_checkin" },
    { member_id: "mem_012", name: "Laide Ogunbiyi", check_in: ISODate("2026-09-01T08:10:00Z"), method: "manual" },
    { member_id: "mem_014", name: "Ngozi Uchenna", check_in: ISODate("2026-09-01T08:25:00Z"), method: "manual" }
  ],
  attendance_count: 12,
  created_at: ISODate("2026-08-30")
});

print("[ok] Event document inserted");

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 5. DONATIONS COLLECTION (time-series style)
// Each donation is a separate document for flexible querying and aggregation.
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

db.donations.insertMany([
  {
    church_id: "church_001",
    member: { member_id: "mem_001", name: "Emeka Okafor" },
    amount: 50000.00,
    currency: "NGN",
    type: "tithe",
    payment_method: "bank_transfer",
    date: ISODate("2026-09-01"),
    recorded_by: "mem_002"
  },
  {
    church_id: "church_001",
    member: { member_id: "mem_003", name: "Tunde Bakare" },
    amount: 30000.00,
    currency: "NGN",
    type: "tithe",
    payment_method: "cash",
    date: ISODate("2026-09-01"),
    recorded_by: "mem_002"
  },
  {
    church_id: "church_001",
    member: null,  // Anonymous donation
    amount: 3000.00,
    currency: "NGN",
    type: "offering",
    payment_method: "cash",
    date: ISODate("2026-09-01"),
    recorded_by: "mem_002"
  },
  {
    church_id: "church_001",
    member: { member_id: "mem_003", name: "Tunde Bakare" },
    amount: 100000.00,
    currency: "NGN",
    type: "building_fund",
    payment_method: "bank_transfer",
    date: ISODate("2026-10-12"),
    recorded_by: "mem_002"
  }
]);

print("[ok] Donation documents inserted");

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 6. SAMPLE QUERIES
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

// Query A: Find all active members of a church with their groups
print("\n--- Query A: Active members with groups ---");
var members = db.members.find(
  { church_id: "church_001", status: "active" },
  { first_name: 1, last_name: 1, "groups.name": 1, "groups.role": 1 }
);
printjson(members.toArray());

// Query B: Aggregation pipeline, total donations by type for a church
print("\n--- Query B: Donations by type ---");
var donationsByType = db.donations.aggregate([
  { $match: { church_id: "church_001" } },
  { $group: {
      _id: "$type",
      total: { $sum: "$amount" },
      count: { $sum: 1 },
      avg_amount: { $avg: "$amount" }
  }},
  { $sort: { total: -1 } }
]);
printjson(donationsByType.toArray());

// Query C: Find events with more than 10 attendees
print("\n--- Query C: Events with 10+ attendees ---");
var largeEvents = db.events.find(
  { attendance_count: { $gte: 10 } },
  { title: 1, start_time: 1, attendance_count: 1 }
);
printjson(largeEvents.toArray());

// Query D: Update attendance, add a new check-in to an event (atomic push)
print("\n--- Query D: Atomic attendance update ---");
db.events.updateOne(
  { _id: "evt_001" },
  {
    $push: {
      attendees: {
        member_id: "mem_015",
        name: "Oluwaseun Falade",
        check_in: new Date(),
        method: "self_checkin"
      }
    },
    $inc: { attendance_count: 1 }
  }
);
print("[ok] New attendee added atomically");

// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ
// 7. INDEXES
// âââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââââ

db.members.createIndex({ church_id: 1, status: 1 });
db.members.createIndex({ "groups.group_id": 1 });
db.donations.createIndex({ church_id: 1, date: -1 });
db.donations.createIndex({ "member.member_id": 1 });
db.events.createIndex({ church_id: 1, start_time: -1 });

print("\n[ok] Indexes created");
print("\n=== MongoDB Document Model Implementation Complete ===");
