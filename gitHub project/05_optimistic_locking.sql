-- ==============================================================================
-- Q5. Optimistic Locking
-- ==============================================================================
-- Problem: 
-- • Add a version column in seats table
-- • Write update query to prevent lost updates using version check

-- ---------------------------------------------------------
-- Note: The `version` column was already added in `01_schema_and_seed.sql`:
-- `version INT DEFAULT 1`
-- ---------------------------------------------------------

-- Scenario: Two users read the same seat status at the same time and attempt to book it.
-- Instead of locking the row (Pessimistic Locking), we use the version number to detect 
-- if the row was modified since we last read it (Optimistic Locking).

-- User A reads the seat
-- Result: status = 'AVAILABLE', version = 1
SELECT seat_id, status, version 
FROM Seats 
WHERE seat_id = 4;

-- User B reads the exact same seat at the exact same time
-- Result: status = 'AVAILABLE', version = 1
SELECT seat_id, status, version 
FROM Seats 
WHERE seat_id = 4;

-- User A initiates the booking and updates the seat.
-- They only update if the version is still 1.
UPDATE Seats 
SET 
    status = 'BOOKED', 
    version = version + 1
WHERE 
    seat_id = 4 
    AND version = 1; -- Crucial check!

-- The above query affects 1 row. User A's booking is successful.

-- Now User B attempts to complete their booking using the version they initially read (1).
UPDATE Seats 
SET 
    status = 'BOOKED', 
    version = version + 1
WHERE 
    seat_id = 4 
    AND version = 1; -- Fails because User A changed the version to 2!

-- The above query affects 0 rows. 
-- The application code checks the "Rows affected" count. Since it is 0, 
-- the application knows someone else updated it and can inform User B:
-- "Sorry, the seat was just booked by someone else."
