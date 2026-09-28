-- =========================================================
-- FitZone Gym Management System
-- PL/pgSQL Functions, Procedures, Triggers & Business Logic
-- =========================================================
-- Prerequisite:
-- Run fitzone_database.sql before executing this file.
-- =========================================================


-- =========================================================
-- 1. BLOCKS, VARIABLES & CONTROL FLOW
-- =========================================================

-- Display the email and booking count of the first member.
DO $$
DECLARE
    v_member_id members.member_id%TYPE;
    v_email members.email%TYPE;
    v_total_bookings INT;
BEGIN
    SELECT member_id, email
    INTO v_member_id, v_email
    FROM members
    ORDER BY member_id
    LIMIT 1;

    SELECT COUNT(*)
    INTO v_total_bookings
    FROM bookings
    WHERE member_id = v_member_id;

    RAISE NOTICE 'Email: %, Total bookings: %', v_email, v_total_bookings;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'An error occurred: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;


-- Check a member's account status.
DO $$
DECLARE
    v_member_status members.status%TYPE;
BEGIN
    SELECT status
    INTO v_member_status
    FROM members
    WHERE member_id = 1;

    IF v_member_status = 'active' THEN
        RAISE NOTICE 'The member account is active.';
    ELSIF v_member_status = 'inactive' THEN
        RAISE NOTICE 'The member account is inactive.';
    ELSE
        RAISE NOTICE 'The member status is not recognized.';
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Iterate through all classes in a selected category.
DO $$
DECLARE
    v_class RECORD;
BEGIN
    FOR v_class IN
        SELECT class_name
        FROM classes
        WHERE category_id = 1
    LOOP
        RAISE NOTICE 'Class: %', v_class.class_name;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Count a trainer's sessions using a cursor and WHILE loop.
DO $$
DECLARE
    v_session_id sessions.session_id%TYPE;
    v_count INT := 0;

    session_cursor CURSOR FOR
        SELECT session_id
        FROM sessions
        WHERE trainer_id = 1;
BEGIN
    OPEN session_cursor;

    FETCH session_cursor INTO v_session_id;

    WHILE FOUND LOOP
        v_count := v_count + 1;
        FETCH session_cursor INTO v_session_id;
    END LOOP;

    CLOSE session_cursor;

    RAISE NOTICE 'Trainer ID 1 - Number of sessions: %', v_count;
END;
$$ LANGUAGE plpgsql;


-- Iterate through the sessions of a class using a RECORD variable.
DO $$
DECLARE
    v_session RECORD;
BEGIN
    FOR v_session IN
        SELECT session_date, room, trainer_id
        FROM sessions
        WHERE class_id = 1
    LOOP
        RAISE NOTICE
            'Session Date: %, Room: %, Trainer ID: %',
            v_session.session_date,
            v_session.room,
            v_session.trainer_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- Display the total number of members.
DO $$
DECLARE
    v_total_members INT;
BEGIN
    SELECT COUNT(*)
    INTO v_total_members
    FROM members;

    RAISE NOTICE 'Total number of members: %', v_total_members;
END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- 2. FUNCTIONS
-- =========================================================

-- Return a member's full name.
CREATE OR REPLACE FUNCTION get_member_full_name(
    p_member_id members.member_id%TYPE
)
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT full_name
        FROM members
        WHERE member_id = p_member_id
    );
END;
$$ LANGUAGE plpgsql;


-- Return the average booking rating for sessions led by a trainer.
CREATE OR REPLACE FUNCTION get_average_rating_by_trainer(
    p_trainer_id trainers.trainer_id%TYPE
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT AVG(b.rating)
        FROM bookings b
        JOIN sessions s
            ON b.session_id = s.session_id
        WHERE s.trainer_id = p_trainer_id
          AND b.rating IS NOT NULL
    );
END;
$$ LANGUAGE plpgsql;


-- Calculate loyalty points based on the number of five-star bookings.
CREATE OR REPLACE FUNCTION calculate_loyalty_points(
    p_member_id members.member_id%TYPE
)
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INT
        FROM bookings
        WHERE member_id = p_member_id
          AND rating = 5
    );
END;
$$ LANGUAGE plpgsql;


-- Return member information for a given email.
CREATE OR REPLACE FUNCTION get_member_by_email(
    p_email members.email%TYPE
)
RETURNS TABLE (
    member_id members.member_id%TYPE,
    full_name members.full_name%TYPE,
    email members.email%TYPE,
    phone_number members.phone_number%TYPE,
    street members.street%TYPE,
    city members.city%TYPE,
    country members.country%TYPE,
    join_date members.join_date%TYPE,
    loyalty_points members.loyalty_points%TYPE,
    status members.status%TYPE
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.member_id,
        m.full_name,
        m.email,
        m.phone_number,
        m.street,
        m.city,
        m.country,
        m.join_date,
        m.loyalty_points,
        m.status
    FROM members m
    WHERE m.email = p_email;

    IF NOT FOUND THEN
        RAISE NOTICE 'No member found with email: %', p_email;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Validate that a rating is between 1 and 5.
CREATE OR REPLACE FUNCTION is_valid_rating(
    p_rating INT
)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN p_rating BETWEEN 1 AND 5;
END;
$$ LANGUAGE plpgsql;


-- Return the number of available seats for a session.
-- Uses the max_capacity stored for the selected session.
CREATE OR REPLACE FUNCTION available_seats(
    p_session_id sessions.session_id%TYPE
)
RETURNS INT AS $$
DECLARE
    v_capacity sessions.max_capacity%TYPE;
    v_booked_seats INT;
BEGIN
    SELECT max_capacity
    INTO v_capacity
    FROM sessions
    WHERE session_id = p_session_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Session ID % was not found.', p_session_id;
        RETURN NULL;
    END IF;

    SELECT COUNT(*)
    INTO v_booked_seats
    FROM bookings
    WHERE session_id = p_session_id;

    RETURN GREATEST(v_capacity - v_booked_seats, 0);
END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- 3. PROCEDURES
-- =========================================================

-- Add a new booking and handle invalid foreign-key values.
CREATE OR REPLACE PROCEDURE add_new_booking(
    p_member_id members.member_id%TYPE,
    p_session_id sessions.session_id%TYPE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO bookings (member_id, session_id)
    VALUES (p_member_id, p_session_id);

    RAISE NOTICE 'Booking added successfully.';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Invalid member ID or session ID. Booking was not added.';
    WHEN unique_violation THEN
        RAISE NOTICE 'This booking already exists.';
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END;
$$;


-- Update a member's account status.
CREATE OR REPLACE PROCEDURE update_member_status(
    p_member_id members.member_id%TYPE,
    p_new_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_new_status NOT IN ('active', 'inactive') THEN
        RAISE NOTICE 'Invalid status. Use active or inactive.';
        RETURN;
    END IF;

    UPDATE members
    SET status = p_new_status
    WHERE member_id = p_member_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'Member ID % was not found.', p_member_id;
    ELSE
        RAISE NOTICE 'Member status updated successfully.';
    END IF;
END;
$$;


-- Apply a loyalty-level bonus to members with more than three bookings.
-- The loyalty level is capped at 5.
CREATE OR REPLACE PROCEDURE apply_loyalty_bonus()
LANGUAGE plpgsql
AS $$
DECLARE
    v_member RECORD;
BEGIN
    FOR v_member IN
        SELECT m.member_id, m.full_name
        FROM members m
        JOIN bookings b
            ON m.member_id = b.member_id
        GROUP BY m.member_id, m.full_name
        HAVING COUNT(b.booking_id) > 3
    LOOP
        UPDATE members
        SET loyalty_level = LEAST(loyalty_level + 1, 5)
        WHERE member_id = v_member.member_id;

        RAISE NOTICE
            'Loyalty level increased for member: %',
            v_member.full_name;
    END LOOP;
END;
$$;


-- =========================================================
-- 4. NAMED EXCEPTION HANDLING EXAMPLES
-- =========================================================

-- Demonstrate handling a duplicate trainer email.
-- The inner block rolls back the failed INSERT automatically.
DO $$
BEGIN
    BEGIN
        INSERT INTO trainers (
            full_name,
            email,
            phone_number,
            hire_date,
            mentor_id,
            years_of_experience
        )
        SELECT
            'Duplicate Email Test',
            email,
            '0799999999',
            CURRENT_DATE,
            NULL,
            1
        FROM trainers
        ORDER BY trainer_id
        LIMIT 1;

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'A trainer with this email already exists.';
    END;
END;
$$ LANGUAGE plpgsql;


-- Demonstrate handling an invalid session foreign key.
DO $$
DECLARE
    v_invalid_session_id INT;
BEGIN
    SELECT COALESCE(MAX(session_id), 0) + 1000
    INTO v_invalid_session_id
    FROM sessions;

    BEGIN
        INSERT INTO bookings (
            member_id,
            session_id
        )
        VALUES (
            (SELECT MIN(member_id) FROM members),
            v_invalid_session_id
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'The session ID does not exist. Booking was not added.';
    END;
END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- 5. LOYALTY LEVEL SUPPORT
-- =========================================================

-- The follow-up database logic uses a loyalty level from 1 to 5.
-- Add the column only if it does not already exist.
ALTER TABLE members
    ADD COLUMN IF NOT EXISTS loyalty_level INT NOT NULL DEFAULT 1;

-- Add a range constraint for loyalty_level when it does not already exist.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_members_loyalty_level'
          AND conrelid = 'members'::regclass
    ) THEN
        ALTER TABLE members
            ADD CONSTRAINT chk_members_loyalty_level
            CHECK (loyalty_level BETWEEN 1 AND 5);
    END IF;
END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- 6. VALIDATION & BUSINESS RULE TRIGGERS
-- =========================================================

-- Prevent a member from booking the same session more than once.
CREATE OR REPLACE FUNCTION prevent_duplicate_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM bookings
        WHERE member_id = NEW.member_id
          AND session_id = NEW.session_id
    ) THEN
        RAISE EXCEPTION 'This member has already booked this session.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_duplicate_booking ON bookings;

CREATE TRIGGER trg_prevent_duplicate_booking
BEFORE INSERT ON bookings
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_booking();


-- Prevent an existing rating from being changed after submission.
CREATE OR REPLACE FUNCTION prevent_rating_update_twice()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.rating IS NOT NULL
       AND NEW.rating IS DISTINCT FROM OLD.rating THEN
        RAISE EXCEPTION
            'The rating has already been submitted and cannot be changed.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_rating_update_twice ON bookings;

CREATE TRIGGER trg_prevent_rating_update_twice
BEFORE UPDATE OF rating ON bookings
FOR EACH ROW
EXECUTE FUNCTION prevent_rating_update_twice();


-- =========================================================
-- 7. AUDIT LOGGING
-- =========================================================

-- Store a history of INSERT, UPDATE, and DELETE operations on bookings.
CREATE TABLE IF NOT EXISTS audit_log (
    audit_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    operation_type VARCHAR(10) NOT NULL,
    booking_id INT,
    member_id INT,
    session_id INT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION log_bookings_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (
            operation_type,
            booking_id,
            member_id,
            session_id
        )
        VALUES (
            'INSERT',
            NEW.booking_id,
            NEW.member_id,
            NEW.session_id
        );

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (
            operation_type,
            booking_id,
            member_id,
            session_id
        )
        VALUES (
            'UPDATE',
            NEW.booking_id,
            NEW.member_id,
            NEW.session_id
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (
            operation_type,
            booking_id,
            member_id,
            session_id
        )
        VALUES (
            'DELETE',
            OLD.booking_id,
            OLD.member_id,
            OLD.session_id
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_bookings_audit ON bookings;

CREATE TRIGGER trg_bookings_audit
AFTER INSERT OR UPDATE OR DELETE ON bookings
FOR EACH ROW
EXECUTE FUNCTION log_bookings_changes();


-- =========================================================
-- 8. AUTOMATIC LOYALTY MANAGEMENT
-- =========================================================

-- Increase a member's loyalty level when a rating is submitted
-- for the first time. The level can never exceed 5.
CREATE OR REPLACE FUNCTION increase_loyalty_level()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.rating IS NULL
       AND NEW.rating IS NOT NULL THEN

        UPDATE members
        SET loyalty_level = LEAST(loyalty_level + 1, 5)
        WHERE member_id = NEW.member_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_increase_loyalty_level ON bookings;

CREATE TRIGGER trg_increase_loyalty_level
AFTER UPDATE OF rating ON bookings
FOR EACH ROW
EXECUTE FUNCTION increase_loyalty_level();


-- =========================================================
-- 9. OPTIONAL SAMPLE CALLS
-- =========================================================
-- The following statements are commented out so that running
-- this file does not intentionally modify the existing sample data.

-- SELECT get_member_full_name(1);
-- SELECT get_average_rating_by_trainer(1);
-- SELECT calculate_loyalty_points(1);
-- SELECT * FROM get_member_by_email('maya.darwish@email.com');
-- SELECT is_valid_rating(5);
-- SELECT available_seats(1);

-- CALL add_new_booking(1, 2);
-- CALL update_member_status(9, 'inactive');
-- CALL apply_loyalty_bonus();

-- =========================================================
-- End of FitZone PL/pgSQL implementation
-- =========================================================
