-- ==============================================================================
-- Q6. Failure & Rollback Handling
-- ==============================================================================
-- Problem: Simulate:
-- • Seat locked but payment fails
-- • Ensure system rolls back and releases seat

-- In a real-world scenario, you book the seat, prompt for payment, 
-- and if the payment gateway returns a failure (or timeout), you must rollback.

-- We use a transaction block. If an error occurs, PostgreSQL automatically aborts the transaction.

BEGIN;

-- 1. Lock the seat for booking (Pessimistic Locking)
SELECT * FROM Seats WHERE seat_id = 5 FOR UPDATE;

-- 2. Temporarily set status to PENDING or BOOKED
UPDATE Seats SET status = 'BOOKED' WHERE seat_id = 5;

-- 3. Insert a Pending Booking
INSERT INTO Bookings (user_id, seat_id, status) VALUES (3, 5, 'PENDING');

-- 4. SIMULATE PAYMENT FAILURE
-- We will simulate a failure by intentionally causing a division by zero error, 
-- or we can just explicitly call ROLLBACK.
-- Let's simulate an application-side decision to rollback.

-- The application receives "Payment Failed" from the API.
-- The application issues a ROLLBACK command to the database.

ROLLBACK;

-- RESULT:
-- The transaction is aborted. 
-- The seat is automatically released (lock dropped).
-- The seat's status reverts back to 'AVAILABLE' in the database.
-- The Bookings insert is undone.

-- Verification:
SELECT status FROM Seats WHERE seat_id = 5; 
-- Output will be 'AVAILABLE'
