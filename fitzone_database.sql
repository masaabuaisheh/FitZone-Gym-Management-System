-- =============================================================
-- FitZone Gym Management System
-- PostgreSQL Database Implementation
-- Includes schema design, sample data, SQL queries, DCL examples,
-- joins, aggregations, subqueries, and indexing.
-- =============================================================

-- SECTION 1: DATABASE SCHEMA (DDL)

-- Table: members
CREATE TABLE members (
    member_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    join_date DATE NOT NULL,
    loyalty_points INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'inactive'))
);

-- Table: trainers
CREATE TABLE trainers (
    trainer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL,
    mentor_id INT,
    years_of_experience INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_trainer_mentor
        FOREIGN KEY (mentor_id)
        REFERENCES trainers(trainer_id)
);

-- Table: categories
CREATE TABLE categories (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(20) NOT NULL,
    description VARCHAR(200)
);

-- Table: classes
CREATE TABLE classes (
    class_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    description VARCHAR(200),
    category_id INT NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Table: sessions
CREATE TABLE sessions (
    session_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(20) NOT NULL,
    max_capacity INT NOT NULL,
    class_id INT NOT NULL REFERENCES classes(class_id) ON DELETE CASCADE,
    trainer_id INT NOT NULL REFERENCES trainers(trainer_id) ON DELETE CASCADE
);

-- Table: bookings
CREATE TABLE bookings (
    booking_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment VARCHAR(200),
	booking_date DATE DEFAULT NOW(),
	member_id INT NOT NULL REFERENCES members(member_id) ON DELETE CASCADE,
    session_id INT NOT NULL REFERENCES sessions(session_id) ON DELETE CASCADE
);


-- Core schema is defined above in its final portfolio-ready form.

-- =========================================================

-- SECTION 2: SAMPLE DATA
-- 1. Insert categories
	-- Exactly 5 categories are inserted
	-- Pilates will have zero classes
INSERT INTO categories (category_name, description)
	VALUES
    	('Yoga', 'Classes that improve flexibility, balance, and relaxation.'),
    	('Cardio', 'High-energy classes that improve fitness and endurance.'),
    	('Weightlifting', 'Classes focused on strength and muscle building.'),
    	('Boxing', 'Classes focused on boxing techniques and physical fitness.'),
    	('Pilates', 'Low-impact exercises focused on posture and core strength.');

-- 2. Insert trainers
	-- Six trainers are inserted
	-- Some trainers will be inserted first without mentors
INSERT INTO trainers (full_name, email, phone_number, hire_date, mentor_id)
	VALUES
    	('Ahmad Al-Hassan', 'ahmad.hassan@fitzone.jo', '0791001001', '2021-02-10', NULL),
		('Lina Al-Khaldi', 'lina.khaldi@fitzone.jo', '0791001002', '2021-06-15', NULL),
		('Samer Al-Odeh', 'samer.odeh@fitzone.jo', '0791001003','2022-01-20', NULL);

-- Insert trainers who have mentors.
	-- Rami is mentored by Ahmad, trainer_id 1
	-- Dana is mentored by Lina, trainer_id 2
INSERT INTO trainers (full_name, email, phone_number, hire_date, mentor_id)
	VALUES 
		('Rami Al-Saleh', 'rami.saleh@fitzone.jo', '0791001004', '2023-03-12', 1),
		('Noor Al-Hamdan', 'noor.hamdan@fitzone.jo', '0791001005', '2022-09-05', NULL),
		('Dana Al-Mansour', 'dana.mansour@fitzone.jo', '0791001006', '2024-01-18', 2);

-- 3. Insert classes
	-- Exactly 10 classes are inserted
	-- Classes belong only to categories 1, 2, 3, and 4
	-- Category 5, Pilates, has zero classes
INSERT INTO classes (class_name, description, category_id)
	VALUES
	    -- Yoga classes
	    ('Morning Yoga', 'A gentle morning yoga class suitable for beginners.', 1),
		('Power Yoga', 'A challenging yoga class focused on balance and strength.', 1),
		('Relaxation Yoga', 'Yoga exercises combined with breathing and relaxation.', 1),

    	-- Cardio classes
    	('HIIT Cardio', 'High-intensity interval training for cardiovascular fitness.', 2),
		('Indoor Cycling', 'Instructor-led cycling exercises with different intensity levels.', 2),
		('Cardio Blast', 'An energetic full-body cardiovascular workout.', 2),
		
		-- Weightlifting classes
    	('Upper Body Training', 'Weightlifting exercises targeting the chest, arms, and back.', 3),
		('Full Body Training', 'Strength training exercises for all major muscle groups.', 3),

	    -- Boxing classes
	    ('Beginner Boxing', 'An introduction to basic boxing movements and techniques.', 4),
		('Boxing Fitness', 'A high-energy workout combining boxing and fitness exercises.', 4);


-- 4. Insert sessions
	-- Exactly 20 sessions are inserted
	-- Each class has two scheduled sessions
INSERT INTO sessions (session_date, start_time, end_time, room, max_capacity, class_id, trainer_id)
	VALUES
	    -- Morning Yoga sessions
	    ('2026-08-01', '08:00', '09:00', 'Studio A', 20, 1, 2),
	    ('2026-08-04', '08:00', '09:00', 'Studio A', 20, 1, 2),
	
	    -- Power Yoga sessions
	    ('2026-08-02', '17:00', '18:00', 'Studio A', 18, 2, 1),
	    ('2026-08-05', '17:00', '18:00', 'Studio A', 18, 2, 1),
	
	    -- Relaxation Yoga sessions
	    ('2026-08-03', '09:00', '10:00', 'Studio B', 15, 3, 6),
	    ('2026-08-06', '09:00', '10:00', 'Studio B', 15, 3, 6),
	
	    -- HIIT Cardio sessions
	    ('2026-08-01', '18:00', '19:00', 'Cardio Hall', 25, 4, 3),
	    ('2026-08-04', '18:00', '19:00', 'Cardio Hall', 25, 4, 3),
	
	    -- Indoor Cycling sessions
	    ('2026-08-02', '19:00', '20:00', 'Cycling Hall', 20, 5, 4),
	    ('2026-08-05', '19:00', '20:00', 'Cycling Hall', 20, 5, 4),
	
	    -- Cardio Blast sessions
	    ('2026-08-03', '18:30', '19:30', 'Cardio Hall', 22, 6, 3),
	    ('2026-08-06', '18:30', '19:30', 'Cardio Hall', 22, 6, 3),
	
	    -- Upper Body Training sessions
	    ('2026-08-01', '16:00', '17:00', 'Weight Room', 15, 7, 1),
	    ('2026-08-04', '16:00', '17:00', 'Weight Room', 15, 7, 1),
	
	    -- Full Body Training sessions
	    ('2026-08-02', '16:00', '17:15', 'Weight Room', 18, 8, 5),
	    ('2026-08-05', '16:00', '17:15', 'Weight Room', 18, 8, 5),
	
	    -- Beginner Boxing sessions
	    ('2026-08-03', '17:00', '18:00', 'Boxing Hall', 20, 9, 4),
	    ('2026-08-06', '17:00', '18:00', 'Boxing Hall', 20, 9, 4),
	
	    -- Boxing Fitness sessions
	    ('2026-08-01', '19:30', '20:30', 'Boxing Hall', 18, 10, 6),
	    ('2026-08-04', '19:30', '20:30', 'Boxing Hall', 18, 10, 6);


-- 5. Insert members
	-- Exactly 10 members are inserted
	-- Member 10, Khaled Musa, will have zero bookings
INSERT INTO members (full_name, email, phone_number, street, city, country, join_date, loyalty_points)
	VALUES
	    ('Maya Darwish',
	     'maya.darwish@email.com',
	     '0792002001',
	     'University Street',
	     'Amman',
	     'Jordan',
	     '2025-01-12',
	     120),
	
	    ('Yousef Hamad',
	     'yousef.hamad@email.com',
	     '0792002002',
	     'King Abdullah Street',
	     'Irbid',
	     'Jordan',
	     '2025-02-20',
	     80),
	
	    ('Sara Nasser',
	     'sara.nasser@email.com',
	     '0792002003',
	     'Wasfi Al-Tal Street',
	     'Zarqa',
	     'Jordan',
	     '2025-03-08',
	     150),
	
	    ('Omar Saleh',
	     'omar.saleh@email.com',
	     '0792002004',
	     'Al-Hussein Street',
	     'Aqaba',
	     'Jordan',
	     '2025-04-15',
	     60),
	
	    ('Rana Odeh',
	     'rana.odeh@email.com',
	     '0792002005',
	     'Palestine Street',
	     'Madaba',
	     'Jordan',
	     '2025-05-02',
	     110),
	
	    ('Tareq Mansour',
	     'tareq.mansour@email.com',
	     '0792002006',
	     'Al-Hammam Street',
	     'Salt',
	     'Jordan',
	     '2025-06-17',
	     40),
	
	    ('Huda Khalil',
	     'huda.khalil@email.com',
	     '0792002007',
	     'Jerash Main Street',
	     'Jerash',
	     'Jordan',
	     '2025-07-09',
	     95),
	
	    ('Ali Hamdan',
	     'ali.hamdan@email.com',
	     '0792002008',
	     'Castle Street',
	     'Karak',
	     'Jordan',
	     '2025-08-25',
	     30),
	
	    ('Lama Shreem',
	     'lama.shreem@email.com',
	     '0792002009',
	     'University Road',
	     'Mafraq',
	     'Jordan',
	     '2025-09-11',
	     70),
	
	    ('Khaled Musa',
	     'khaled.musa@email.com',
	     '0782002010',
	     'Ajloun Main Street',
	     'Ajloun',
	     'Jordan',
	     '2026-01-06',
	     0);


-- 6. Insert bookings
	-- Exactly 20 bookings are inserted
	-- Members 1 through 9 have bookings
	-- Member 10 has zero bookings
	-- 17 bookings have ratings
	-- 3 bookings have NULL ratings
INSERT INTO bookings (rating, comment, booking_date, member_id, session_id)
	VALUES
	    (5, 'Excellent and relaxing yoga class.', '2026-07-20', 1, 1),
	    (4, 'The trainer explained everything clearly.', '2026-07-21', 1, 4),
	    (5, 'A challenging and enjoyable workout.', '2026-07-22', 1, 7),
	    (4, 'Good session with positive energy.', '2026-07-20', 2, 2),
	    (3, 'The class was useful but very intense.', '2026-07-23', 2, 9),
	    (5, 'I enjoyed the breathing exercises.', '2026-07-21', 3, 5),
	    (5, 'Excellent boxing class.', '2026-07-22', 3, 17),
	    (4, 'The exercises were enjoyable.', '2026-07-24', 3, 19),
	    (3, 'The room was slightly crowded.', '2026-07-20', 4, 8),
	    (4, 'A well-organized strength session.', '2026-07-24', 4, 13),
	    (5, 'The cycling session was excellent.', '2026-07-21', 5, 10),
	    (4, 'A great full-body workout.', '2026-07-25', 5, 15),
	    (3, 'The session was difficult for a beginner.', '2026-07-22', 6, 11),	
	    (4, 'The trainer was supportive and professional.', '2026-07-25', 6, 16),
	    (5, 'One of the best yoga classes I attended.', '2026-07-23', 7, 3),
	    (4, 'A very energetic cardio class.', '2026-07-26', 7, 12),
	    (5, 'The boxing trainer was excellent.','2026-07-24', 8, 18),
	    (NULL, NULL,'2026-07-26', 8, 20),
		(NULL, NULL,'2026-07-25', 9, 6),
	    (NULL, NULL,'2026-07-27', 9, 14);


-- =========================================================

-- SECTION 3: SQL FUNDAMENTALS & DML
-- 3. Show all members (full name and email) ordered by join date ascending, 
-- using AS to alias the full name column
SELECT full_name AS member_name, email 
	FROM members 
	ORDER BY join_date ASC;

-- 4. Show the distinct cities found in the members table.
SELECT DISTINCT city FROM members;

-- 5. Show only the members whose status is 'active'.
UPDATE members
	SET status = 'inactive'
	WHERE member_id = 9;
	WHERE status = 'active';

-- 6. UPDATE a trainer's years of experience, 
-- using RETURNING to return the row after the update.
UPDATE trainers
	SET years_of_experience = 9
	WHERE trainer_id = 1
	RETURNING
	    trainer_id,
	    full_name,
	    years_of_experience;

-- 7. DELETE one dummy booking you inserted specifically for this purpose, 
-- using RETURNING to return the deleted row.
INSERT INTO bookings (rating, comment, booking_date, member_id, session_id)
	VALUES
	    (5, 'Dummy booking for deletion test.', '2026-07-20', 1, 1);

DELETE FROM bookings
	WHERE comment = 'Dummy booking for deletion test.'
	RETURNING
	    booking_id,
	    rating,
	    comment,
	    booking_date,
	    member_id,
	    session_id;

-- =========================================================

-- SECTION 4: SECURITY & ADMINISTRATION (DCL)
-- DCL demonstration only. Replace placeholder passwords before running.
-- Create a read-only user
CREATE USER readonly_user WITH PASSWORD 'replace_with_secure_password';

-- 1. Allow the user to connect to the database.
GRANT CONNECT ON DATABASE fitzone_db TO readonly_user;

-- 2. Allow access to the public schema.
GRANT USAGE ON SCHEMA public TO readonly_user;

-- 3. Grant read-only access to all existing tables.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- Create an operations manager user
CREATE USER manager_user WITH PASSWORD 'replace_with_secure_password';

-- 1. Allow the user to connect to the database
GRANT CONNECT ON DATABASE fitzone_db TO manager_user;

-- 2. Allow access to the public schema
GRANT USAGE ON SCHEMA public TO manager_user;

-- 3. Grant permissions to view, insert, and update data
GRANT SELECT, INSERT, UPDATE
	ON ALL TABLES IN SCHEMA public
	TO manager_user;

-- Revoke UPDATE permission on the members table
REVOKE UPDATE
	ON members
	FROM manager_user;

-- A Database Administrator (DBA) manages database users and controls their permissions
-- Different employees receive different access depending on their job
-- For example, a read-only user can view data but cannot modify it, while a manager can view,
-- insert, and update records. If a user no longer needs certain permissions, 
-- the DBA can revoke them to protect the database and improve security


-- =========================================================

-- SECTION 5: JOINS
-- 8. Show every session with its class name
-- and the responsible trainer's name.
SELECT
    s.session_id,
    s.session_date,
    s.start_time,
    s.end_time,
    c.class_name,
    t.full_name AS trainer_name
	FROM sessions s
	INNER JOIN classes c
	    ON s.class_id = c.class_id
	INNER JOIN trainers t
	    ON s.trainer_id = t.trainer_id
	ORDER BY s.session_date, s.start_time;

-- 9. Show all members with their booking count,
-- including members with zero bookings.
SELECT
    m.member_id,
    m.full_name AS member_name,
    COUNT(b.booking_id) AS booking_count
	FROM members m
	LEFT JOIN bookings b
	    ON m.member_id = b.member_id
	GROUP BY
	    m.member_id,
	    m.full_name
	ORDER BY m.member_id;

-- 10. Show all sessions with their booking count,
-- including sessions that have zero bookings.
SELECT
    s.session_id,
    s.session_date,
    s.start_time,
    COUNT(b.booking_id) AS booking_count
	FROM bookings b
	RIGHT JOIN sessions s
	    ON b.session_id = s.session_id
	GROUP BY
	    s.session_id,
	    s.session_date,
	    s.start_time
	ORDER BY s.session_id;

-- 11. Show all categories together with all classes,
-- including categories that have zero classes.
SELECT
    c.category_id,
    c.category_name,
    cl.class_id,
    cl.class_name
	FROM categories c
	FULL OUTER JOIN classes cl
	    ON c.category_id = cl.category_id
	ORDER BY c.category_id, cl.class_id;

-- 12. Show each trainer with their mentor's name,
-- if the trainer has a mentor.
SELECT
    t.trainer_id,
    t.full_name AS trainer_name,
    m.full_name AS mentor_name
FROM trainers t
LEFT JOIN trainers m
    ON t.mentor_id = m.trainer_id
ORDER BY t.trainer_id;

-- =========================================================

-- SECTION 6: AGGREGATION, GROUPING & SUBQUERIES
-- 13. Count  the number of bookings per member.
SELECT
    m.member_id,
    m.full_name AS member_name,
    COUNT(b.booking_id) AS booking_count
	FROM members m
	LEFT JOIN bookings b
	    ON m.member_id = b.member_id
	GROUP BY
	    m.member_id,
	    m.full_name
	ORDER BY m.member_id;

-- 14. Average rating per trainer, based on the rating column in bookings.
SELECT
    t.trainer_id,
    t.full_name AS trainer_name,
    ROUND(AVG(b.rating), 2) AS average_rating
	FROM trainers t
	LEFT JOIN sessions s
	    ON t.trainer_id = s.trainer_id
	LEFT JOIN bookings b
	    ON s.session_id = b.session_id
	GROUP BY
	    t.trainer_id,
	    t.full_name
	ORDER BY t.trainer_id;
	
-- 15. Highest and lowest rating  given for each class.
SELECT
    c.class_id,
    c.class_name,
    MAX(b.rating) AS highest_rating,
    MIN(b.rating) AS lowest_rating
	FROM classes c
	LEFT JOIN sessions s
	    ON c.class_id = s.class_id
	LEFT JOIN bookings b
	    ON s.session_id = b.session_id
	GROUP BY
	    c.class_id,
	    c.class_name
	ORDER BY c.class_id;

-- 16. Total loyalty_points across all members, grouped by city.
SELECT
    city,
    SUM(loyalty_points) AS total_loyalty_points
	FROM members
	GROUP BY city
	ORDER BY city;

-- 17. Use GROUP BY with HAVING to show categories that have more than two classes.
SELECT
    c.category_id,
    c.category_name,
    COUNT(cl.class_id) AS class_count
	FROM categories c
	LEFT JOIN classes cl
	    ON c.category_id = cl.category_id
	GROUP BY
	    c.category_id,
	    c.category_name
	HAVING COUNT(cl.class_id) > 2
	ORDER BY class_count DESC;

-- 18. Show members who have never made a booking (using NOT IN or NOT EXISTS).
SELECT
    m.member_id,
    m.full_name AS member_name
	FROM members m
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bookings b
	    WHERE b.member_id = m.member_id
	)
	ORDER BY m.member_id;

-- 19. Show trainers whose average rating is above the overall average rating of all trainers.
SELECT
    t.trainer_id,
    t.full_name AS trainer_name,
    ROUND(AVG(b.rating), 2) AS trainer_average_rating
FROM trainers t
JOIN sessions s
    ON t.trainer_id = s.trainer_id
JOIN bookings b
    ON s.session_id = b.session_id
WHERE b.rating IS NOT NULL
GROUP BY
    t.trainer_id,
    t.full_name
HAVING AVG(b.rating) > (
    SELECT AVG(rating)
    FROM bookings
    WHERE rating IS NOT NULL
)
ORDER BY trainer_average_rating DESC;

-- =========================================================

-- SECTION 7: INDEXING
-- 1. Create an index on the email column in the members table
-- This improves searches for members by email address
CREATE INDEX idx_members_email
ON members(email);

-- 2. Create an index on the session_id column in the bookings table
-- This improves searches and joins involving sessions
CREATE INDEX idx_bookings_session_id
ON bookings(session_id);

-- 3. Drop one index as a test
DROP INDEX idx_members_email;

SELECT
    indexname,
    tablename
FROM pg_indexes
WHERE tablename IN ('members', 'bookings');
