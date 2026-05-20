-- ==============================================================================
-- Q3. Parallel Booking Handling
-- ==============================================================================
-- Problem: Write a query using FOR UPDATE SKIP LOCKED to allow multiple users 
-- to book different seats simultaneously without waiting.

-- Explanation:
-- In a high-concurrency ticket system (like IRCTC or BookMyShow), hundreds of users
-- might try to book seats for the same movie. If User A locks seat 1, User B shouldn't
-- have to wait for User A to finish just to see what other seats are available.
-- SKIP LOCKED allows User B's query to completely skip any rows currently locked by User A.

-- Query: Fetch the next 2 available seats for a specific show that are NOT currently locked by anyone else.

BEGIN;

-- User 1 starts a transaction and fetches available seats
SELECT seat_id, seat_number, status 
FROM Seats
WHERE show_id = 1 AND status = 'AVAILABLE'
ORDER BY seat_id
LIMIT 2
FOR UPDATE SKIP LOCKED;

-- At this exact moment, if User 2 runs the exact same query in another terminal:
-- User 2 will NOT see the seats returned to User 1. 
-- Instead of waiting/blocking, User 2 gets the NEXT 2 available seats instantly.

-- Simulate booking for User 1
UPDATE Seats
SET status = 'BOOKED'
WHERE seat_id IN (
    SELECT seat_id 
    FROM Seats
    WHERE show_id = 1 AND status = 'AVAILABLE'
    ORDER BY seat_id
    LIMIT 2
    FOR UPDATE SKIP LOCKED
);

-- Insert into bookings...
INSERT INTO Bookings (user_id, seat_id, status)
VALUES 
    (2, 2, 'CONFIRMED'), 
    (2, 3, 'CONFIRMED');

COMMIT;
