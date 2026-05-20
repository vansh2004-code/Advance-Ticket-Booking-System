-- ==============================================================================
-- Q7. Isolation Level Analysis
-- ==============================================================================
-- Problem: Set and test different isolation levels (READ COMMITTED, SERIALIZABLE)
-- Explain their impact on Seat availability & Booking consistency.

-- ---------------------------------------------------------
-- Level 1: READ COMMITTED (Default in most RDBMS like Postgres)
-- ---------------------------------------------------------
-- Impact: Transactions can see changes committed by other transactions during their execution.
-- Result: No "dirty reads" (reading uncommitted data), but "non-repeatable reads" are possible.

-- Simulation:
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT count(*) FROM Seats WHERE status = 'AVAILABLE'; -- Returns 10

-- Terminal 2:
BEGIN;
UPDATE Seats SET status = 'BOOKED' WHERE seat_id = 1;
COMMIT;

-- Terminal 1:
SELECT count(*) FROM Seats WHERE status = 'AVAILABLE'; -- Returns 9 (The count changed within the same transaction!)
COMMIT;
-- Analysis: For a booking system, this is generally acceptable for checking available seats, 
-- but when actually BOOKING, we must use row locks (`FOR UPDATE`) to prevent concurrent updates.

-- ---------------------------------------------------------
-- Level 2: SERIALIZABLE (Strictest Level)
-- ---------------------------------------------------------
-- Impact: Ensures that concurrent transactions execute as if they were strictly sequential.
-- Result: Prevents "phantom reads". If two transactions try to modify data based on overlapping reads, 
-- one will be forced to abort with a serialization error.

-- Simulation:
-- Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM Seats WHERE show_id = 2; -- Reads all seats for Show 2

-- Terminal 2:
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM Seats WHERE show_id = 2; -- Reads all seats for Show 2
UPDATE Seats SET status = 'BOOKED' WHERE seat_id = 6; -- Succeeds temporarily
COMMIT; -- Succeeds

-- Terminal 1:
UPDATE Seats SET status = 'BOOKED' WHERE seat_id = 7;
-- ERROR: could not serialize access due to read/write dependencies among transactions
-- HINT: The transaction might succeed if retried.
ROLLBACK;

-- Analysis: SERIALIZABLE provides 100% consistency and guarantees no double bookings without 
-- needing explicit `FOR UPDATE` locks on reads. However, it leads to HIGH transaction failure 
-- rates in a busy system. 
-- In real-world booking systems, READ COMMITTED with explicit row-level locking (Pessimistic) 
-- or Optimistic Locking (Versioning) is heavily preferred over full SERIALIZABLE isolation for better performance.
