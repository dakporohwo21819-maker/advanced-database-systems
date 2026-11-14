-- =============================================================================
-- Shepherd App, Seed Data for Query Optimisation Portfolio
-- =============================================================================

-- Churches
INSERT INTO churches (name, denomination, address, city, country, phone, email, website, founded_date)
VALUES
('Grace Chapel Lagos', 'Pentecostal', '15 Admiralty Way, Lekki', 'Lagos', 'Nigeria', '+234-801-234-5678', 'info@gracechapel.ng', 'https://gracechapel.ng', '2010-03-15'),
('Covenant Assembly Abuja', 'Non-denominational', '42 Wuse II Drive', 'Abuja', 'Nigeria', '+234-802-345-6789', 'admin@covenantabuja.org', 'https://covenantabuja.org', '2015-07-01'),
('Harvesters Church PH', 'Charismatic', '8 Rumuola Road', 'Port Harcourt', 'Nigeria', '+234-803-456-7890', 'hello@harvestersph.org', NULL, '2018-11-20');

-- Users
INSERT INTO users (church_id, first_name, last_name, email, password_hash, role)
VALUES
(1, 'Emeka', 'Okafor', 'emeka@gracechapel.ng', '$2b$12$fakehash1', 'pastor'),
(1, 'Blessing', 'Adekunle', 'blessing@gracechapel.ng', '$2b$12$fakehash2', 'admin'),
(1, 'Tunde', 'Bakare', 'tunde@gracechapel.ng', '$2b$12$fakehash3', 'leader'),
(2, 'Sarah', 'Musa', 'sarah@covenantabuja.org', '$2b$12$fakehash4', 'pastor'),
(2, 'Ibrahim', 'Yusuf', 'ibrahim@covenantabuja.org', '$2b$12$fakehash5', 'admin'),
(3, 'Chioma', 'Nwosu', 'chioma@harvestersph.org', '$2b$12$fakehash6', 'pastor');

-- Members (30 members across 3 churches)
INSERT INTO members (church_id, user_id, first_name, last_name, gender, date_of_birth, phone, email, member_since, status)
VALUES
-- Grace Chapel (church 1), 15 members
(1, 1, 'Emeka', 'Okafor', 'Male', '1980-05-10', '08012345678', 'emeka@gracechapel.ng', '2010-03-15', 'active'),
(1, 2, 'Blessing', 'Adekunle', 'Female', '1992-08-22', '08023456789', 'blessing@gracechapel.ng', '2012-01-10', 'active'),
(1, 3, 'Tunde', 'Bakare', 'Male', '1988-11-03', '08034567890', 'tunde@gracechapel.ng', '2013-06-20', 'active'),
(1, NULL, 'Adaeze', 'Obi', 'Female', '1995-02-14', '08045678901', 'adaeze.obi@gmail.com', '2016-09-05', 'active'),
(1, NULL, 'Chukwudi', 'Eze', 'Male', '1990-12-25', '08056789012', 'chukwudi.eze@yahoo.com', '2017-03-18', 'active'),
(1, NULL, 'Folake', 'Adeyemi', 'Female', '1985-07-30', '08067890123', 'folake.a@gmail.com', '2014-11-01', 'active'),
(1, NULL, 'Gbenga', 'Olumide', 'Male', '1978-04-08', '08078901234', 'gbenga.o@outlook.com', '2011-05-22', 'active'),
(1, NULL, 'Halima', 'Bello', 'Female', '1998-01-17', '08089012345', 'halima.b@gmail.com', '2020-02-14', 'active'),
(1, NULL, 'Ikenna', 'Nnamdi', 'Male', '1993-09-09', '08090123456', 'ikenna.n@gmail.com', '2019-07-07', 'active'),
(1, NULL, 'Jumoke', 'Fashola', 'Female', '2000-06-12', '08001234567', 'jumoke.f@gmail.com', '2021-01-03', 'active'),
(1, NULL, 'Kelechi', 'Amadi', 'Male', '1987-03-28', '07012345678', 'kelechi.a@gmail.com', '2015-08-15', 'inactive'),
(1, NULL, 'Laide', 'Ogunbiyi', 'Female', '1991-10-05', '07023456789', 'laide.o@gmail.com', '2018-04-20', 'active'),
(1, NULL, 'Muyiwa', 'Akinola', 'Male', '1982-08-19', '07034567890', 'muyiwa.a@gmail.com', '2012-12-01', 'transferred'),
(1, NULL, 'Ngozi', 'Uchenna', 'Female', '1996-05-25', '07045678901', 'ngozi.u@gmail.com', '2022-03-10', 'active'),
(1, NULL, 'Oluwaseun', 'Falade', 'Male', '1989-11-11', '07056789012', 'seun.f@gmail.com', '2016-06-30', 'active'),

-- Covenant Assembly (church 2), 10 members
(2, 4, 'Sarah', 'Musa', 'Female', '1983-02-20', '09012345678', 'sarah@covenantabuja.org', '2015-07-01', 'active'),
(2, 5, 'Ibrahim', 'Yusuf', 'Male', '1990-06-15', '09023456789', 'ibrahim@covenantabuja.org', '2016-01-15', 'active'),
(2, NULL, 'Amina', 'Abdullahi', 'Female', '1994-09-03', '09034567890', 'amina.a@gmail.com', '2017-05-20', 'active'),
(2, NULL, 'Danladi', 'Garba', 'Male', '1986-12-10', '09045678901', 'danladi.g@gmail.com', '2018-02-28', 'active'),
(2, NULL, 'Esther', 'Bako', 'Female', '1997-04-18', '09056789012', 'esther.b@gmail.com', '2019-09-14', 'active'),
(2, NULL, 'Fatima', 'Mohammed', 'Female', '1992-07-22', '09067890123', 'fatima.m@gmail.com', '2020-01-05', 'active'),
(2, NULL, 'Gareth', 'Okoro', 'Male', '1988-01-30', '09078901234', 'gareth.o@gmail.com', '2016-11-11', 'inactive'),
(2, NULL, 'Hauwa', 'Suleiman', 'Female', '1999-03-08', '09089012345', 'hauwa.s@gmail.com', '2021-06-01', 'active'),
(2, NULL, 'Joseph', 'Tanko', 'Male', '1984-10-14', '09090123456', 'joseph.t@gmail.com', '2017-08-20', 'active'),
(2, NULL, 'Khadija', 'Abubakar', 'Female', '1995-11-27', '09001234567', 'khadija.a@gmail.com', '2022-04-15', 'active'),

-- Harvesters PH (church 3), 5 members
(3, 6, 'Chioma', 'Nwosu', 'Female', '1986-08-05', '08112345678', 'chioma@harvestersph.org', '2018-11-20', 'active'),
(3, NULL, 'Obinna', 'Agu', 'Male', '1991-04-12', '08123456789', 'obinna.a@gmail.com', '2019-03-10', 'active'),
(3, NULL, 'Nneka', 'Okonkwo', 'Female', '1993-07-29', '08134567890', 'nneka.o@gmail.com', '2020-01-20', 'active'),
(3, NULL, 'Uche', 'Iheanacho', 'Male', '1987-12-16', '08145678901', 'uche.i@gmail.com', '2019-08-05', 'active'),
(3, NULL, 'Yetunde', 'Alabi', 'Female', '1998-02-03', '08156789012', 'yetunde.a@gmail.com', '2021-11-15', 'active');

-- Groups
INSERT INTO groups (church_id, name, description, group_type, leader_id)
VALUES
(1, 'Choir', 'Music and worship team', 'choir', 3),
(1, 'Youth Ministry', 'Young adults 18-35', 'youth', 4),
(1, 'Media Unit', 'Sound, projector, and livestream', 'unit', 5),
(1, 'Prayer Warriors', 'Intercessory prayer team', 'department', 6),
(1, 'Children Church', 'Kids ages 3-12', 'children', 2),
(2, 'Ushering Team', 'Welcome and ushering', 'department', 16),
(2, 'Bible Study Group', 'Weekly midweek study', 'cell', 17),
(3, 'Evangelism Team', 'Outreach and evangelism', 'department', 26);

-- Group members
INSERT INTO group_members (group_id, member_id, role_in_group, joined_at)
VALUES
(1, 3, 'leader', '2013-06-20'), (1, 4, 'member', '2016-10-01'), (1, 8, 'member', '2020-03-01'),
(1, 10, 'member', '2021-02-01'), (1, 12, 'member', '2018-05-01'),
(2, 4, 'leader', '2016-09-05'), (2, 8, 'member', '2020-02-20'), (2, 9, 'member', '2019-08-01'),
(2, 10, 'member', '2021-01-10'), (2, 14, 'member', '2022-04-01'),
(3, 5, 'leader', '2017-04-01'), (3, 9, 'member', '2019-08-01'), (3, 15, 'member', '2016-07-01'),
(4, 6, 'leader', '2014-11-01'), (4, 7, 'member', '2011-06-01'), (4, 1, 'member', '2010-04-01'),
(5, 2, 'leader', '2012-02-01'), (5, 10, 'member', '2021-02-01'),
(6, 16, 'leader', '2015-07-01'), (6, 18, 'member', '2017-06-01'), (6, 19, 'member', '2018-03-01'),
(7, 17, 'leader', '2016-02-01'), (7, 20, 'member', '2019-10-01'), (7, 21, 'member', '2020-02-01'),
(8, 26, 'leader', '2018-11-20'), (8, 27, 'member', '2019-04-01'), (8, 28, 'member', '2020-02-01');

-- Events (various types across churches over several months)
INSERT INTO events (church_id, title, event_type, location, start_time, end_time, is_recurring, created_by)
VALUES
(1, 'Sunday Service', 'service', 'Main Auditorium', '2026-09-01 09:00+01', '2026-09-01 12:00+01', TRUE, 1),
(1, 'Sunday Service', 'service', 'Main Auditorium', '2026-09-08 09:00+01', '2026-09-08 12:00+01', TRUE, 1),
(1, 'Sunday Service', 'service', 'Main Auditorium', '2026-09-15 09:00+01', '2026-09-15 12:00+01', TRUE, 1),
(1, 'Sunday Service', 'service', 'Main Auditorium', '2026-09-22 09:00+01', '2026-09-22 12:00+01', TRUE, 1),
(1, 'Midweek Prayer', 'prayer', 'Chapel', '2026-09-03 18:00+01', '2026-09-03 20:00+01', TRUE, 1),
(1, 'Midweek Prayer', 'prayer', 'Chapel', '2026-09-10 18:00+01', '2026-09-10 20:00+01', TRUE, 1),
(1, 'Youth Conference 2026', 'conference', 'Main Auditorium', '2026-10-05 10:00+01', '2026-10-05 17:00+01', FALSE, 3),
(1, 'Community Outreach', 'outreach', 'Lekki Market Area', '2026-10-12 08:00+01', '2026-10-12 14:00+01', FALSE, 2),
(2, 'Sunday Worship', 'service', 'Main Hall', '2026-09-01 10:00+01', '2026-09-01 13:00+01', TRUE, 4),
(2, 'Sunday Worship', 'service', 'Main Hall', '2026-09-08 10:00+01', '2026-09-08 13:00+01', TRUE, 4),
(2, 'Bible Study', 'meeting', 'Room 3', '2026-09-04 18:30+01', '2026-09-04 20:00+01', TRUE, 5),
(3, 'Sunday Celebration', 'service', 'Church Hall', '2026-09-01 08:30+01', '2026-09-01 11:30+01', TRUE, 6),
(3, 'Sunday Celebration', 'service', 'Church Hall', '2026-09-08 08:30+01', '2026-09-08 11:30+01', TRUE, 6);

-- Attendance (spread across events)
INSERT INTO attendance (event_id, member_id, check_in_time, check_in_method)
VALUES
-- Sunday 1 Sep (Grace Chapel, event 1)
(1,1,'2026-09-01 08:50+01','manual'),(1,2,'2026-09-01 08:55+01','manual'),(1,3,'2026-09-01 09:05+01','qr_code'),
(1,4,'2026-09-01 09:00+01','qr_code'),(1,5,'2026-09-01 09:10+01','manual'),(1,6,'2026-09-01 08:45+01','manual'),
(1,7,'2026-09-01 09:15+01','manual'),(1,8,'2026-09-01 09:20+01','self_checkin'),(1,9,'2026-09-01 09:00+01','qr_code'),
(1,10,'2026-09-01 09:05+01','self_checkin'),(1,12,'2026-09-01 09:10+01','manual'),(1,14,'2026-09-01 09:25+01','manual'),
-- Sunday 8 Sep (Grace Chapel, event 2)
(2,1,'2026-09-08 08:55+01','manual'),(2,2,'2026-09-08 09:00+01','manual'),(2,4,'2026-09-08 09:05+01','qr_code'),
(2,5,'2026-09-08 09:10+01','manual'),(2,6,'2026-09-08 08:50+01','manual'),(2,7,'2026-09-08 09:00+01','manual'),
(2,8,'2026-09-08 09:15+01','self_checkin'),(2,9,'2026-09-08 09:20+01','qr_code'),(2,10,'2026-09-08 09:05+01','self_checkin'),
(2,15,'2026-09-08 09:30+01','manual'),
-- Sunday 15 Sep (Grace Chapel, event 3)
(3,1,'2026-09-15 09:00+01','manual'),(3,2,'2026-09-15 08:55+01','manual'),(3,3,'2026-09-15 09:10+01','qr_code'),
(3,4,'2026-09-15 09:05+01','qr_code'),(3,6,'2026-09-15 08:50+01','manual'),(3,8,'2026-09-15 09:20+01','self_checkin'),
(3,12,'2026-09-15 09:15+01','manual'),(3,14,'2026-09-15 09:30+01','manual'),
-- Midweek Prayer 3 Sep (event 5)
(5,1,'2026-09-03 17:55+01','manual'),(5,6,'2026-09-03 18:00+01','manual'),(5,7,'2026-09-03 18:05+01','manual'),
(5,3,'2026-09-03 18:10+01','manual'),
-- Youth Conference (event 7)
(7,4,'2026-10-05 09:50+01','qr_code'),(7,8,'2026-10-05 09:55+01','qr_code'),(7,9,'2026-10-05 10:00+01','qr_code'),
(7,10,'2026-10-05 10:05+01','qr_code'),(7,14,'2026-10-05 10:10+01','qr_code'),
-- Covenant Assembly Sunday 1 Sep (event 9)
(9,16,'2026-09-01 09:55+01','manual'),(9,17,'2026-09-01 10:00+01','manual'),(9,18,'2026-09-01 10:05+01','manual'),
(9,19,'2026-09-01 10:10+01','manual'),(9,20,'2026-09-01 10:15+01','manual'),(9,21,'2026-09-01 10:00+01','manual'),
(9,23,'2026-09-01 10:20+01','manual'),(9,24,'2026-09-01 10:05+01','manual'),
-- Harvesters Sunday 1 Sep (event 12)
(12,26,'2026-09-01 08:25+01','manual'),(12,27,'2026-09-01 08:30+01','manual'),(12,28,'2026-09-01 08:35+01','manual'),
(12,29,'2026-09-01 08:40+01','manual');

-- Donations (spread over Sep-Oct 2026)
INSERT INTO donations (church_id, member_id, amount, currency, donation_type, payment_method, donation_date, recorded_by)
VALUES
-- Grace Chapel tithes and offerings
(1, 1, 50000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-01', 2),
(1, 2, 25000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-01', 2),
(1, 3, 30000.00, 'NGN', 'tithe', 'cash', '2026-09-01', 2),
(1, 4, 15000.00, 'NGN', 'offering', 'mobile_money', '2026-09-01', 2),
(1, 5, 20000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-08', 2),
(1, 6, 10000.00, 'NGN', 'offering', 'cash', '2026-09-08', 2),
(1, 7, 45000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-15', 2),
(1, 8, 5000.00, 'NGN', 'offering', 'mobile_money', '2026-09-15', 2),
(1, 9, 18000.00, 'NGN', 'tithe', 'card', '2026-09-22', 2),
(1, 1, 50000.00, 'NGN', 'tithe', 'bank_transfer', '2026-10-06', 2),
(1, 2, 25000.00, 'NGN', 'tithe', 'bank_transfer', '2026-10-06', 2),
(1, 4, 10000.00, 'NGN', 'seed', 'cash', '2026-10-05', 2),
(1, NULL, 3000.00, 'NGN', 'offering', 'cash', '2026-09-01', 2),
(1, NULL, 5000.00, 'NGN', 'offering', 'cash', '2026-09-08', 2),
(1, 10, 8000.00, 'NGN', 'offering', 'online', '2026-09-15', 2),
(1, 3, 100000.00, 'NGN', 'building_fund', 'bank_transfer', '2026-10-12', 2),
-- Covenant Assembly
(2, 16, 40000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-01', 5),
(2, 17, 20000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-01', 5),
(2, 18, 12000.00, 'NGN', 'offering', 'cash', '2026-09-01', 5),
(2, 19, 35000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-08', 5),
(2, 20, 8000.00, 'NGN', 'offering', 'mobile_money', '2026-09-08', 5),
(2, 16, 40000.00, 'NGN', 'tithe', 'bank_transfer', '2026-10-06', 5),
-- Harvesters
(3, 26, 30000.00, 'NGN', 'tithe', 'bank_transfer', '2026-09-01', 6),
(3, 27, 15000.00, 'NGN', 'tithe', 'card', '2026-09-01', 6),
(3, 28, 7000.00, 'NGN', 'offering', 'cash', '2026-09-08', 6);

-- Pledges
INSERT INTO pledges (church_id, member_id, campaign, amount_pledged, amount_fulfilled, due_date, status)
VALUES
(1, 1, 'Building Fund 2026', 500000.00, 100000.00, '2026-12-31', 'active'),
(1, 3, 'Building Fund 2026', 300000.00, 100000.00, '2026-12-31', 'active'),
(1, 7, 'Building Fund 2026', 200000.00, 0.00, '2026-12-31', 'active'),
(1, 5, 'Youth Conference Sponsorship', 50000.00, 50000.00, '2026-10-01', 'fulfilled'),
(2, 16, 'Missions Fund', 100000.00, 40000.00, '2027-03-31', 'active'),
(2, 19, 'Missions Fund', 75000.00, 0.00, '2027-03-31', 'active');

-- Communications
INSERT INTO communications (church_id, subject, body, channel, target_type, target_group_id, sent_by, sent_at, status)
VALUES
(1, 'Sunday Service Reminder', 'Dear members, join us this Sunday at 9am. God bless!', 'sms', 'all', NULL, 1, '2026-08-31 18:00+01', 'sent'),
(1, 'Youth Conference Registration', 'Register for the Youth Conference on 5 Oct. Limited seats!', 'whatsapp', 'group', 2, 3, '2026-09-20 10:00+01', 'sent'),
(1, 'Building Fund Update', 'We have raised 60% of our target. Thank you for your generosity.', 'email', 'all', NULL, 1, '2026-10-15 09:00+01', 'sent'),
(2, 'Midweek Bible Study', 'Join us Wednesday at 6:30pm in Room 3.', 'sms', 'group', 7, 4, '2026-09-03 12:00+01', 'sent');

-- Communication recipients (sample)
INSERT INTO communication_recipients (communication_id, member_id, delivered, delivered_at)
VALUES
(1,1,TRUE,'2026-08-31 18:01+01'),(1,2,TRUE,'2026-08-31 18:01+01'),(1,3,TRUE,'2026-08-31 18:02+01'),
(1,4,TRUE,'2026-08-31 18:01+01'),(1,5,TRUE,'2026-08-31 18:03+01'),(1,6,FALSE,NULL),
(2,4,TRUE,'2026-09-20 10:01+01'),(2,8,TRUE,'2026-09-20 10:01+01'),(2,9,TRUE,'2026-09-20 10:02+01'),
(2,10,TRUE,'2026-09-20 10:01+01'),(2,14,TRUE,'2026-09-20 10:03+01');
