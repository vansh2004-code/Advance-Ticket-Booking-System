-- ==============================================================================
-- Q4. Deadlock Simulation
-- ==============================================================================
-- Problem: 
-- • Create a scenario where two transactions try to lock seats in reverse order
-- • Show how deadlock occurs
-- • Write a strategy to prevent it

-- ---------------------------------------------------------
-- PART A: Deadlock Scenario (Run in two separate terminals)
-- ---------------------------------------------------------

-- [Terminal 1 - Transaction A]
BEGIN;
-- Lock Seat 1
SELECT * FROM Seats WHERE seat_id = 1 FOR UPDATE;

-- [Terminal 2 - Transaction B]
BEGIN;
-- Lock Seat 2
SELECT * FROM Seats WHERE seat_id = 2 FOR UPDATE;

-- [Terminal 1 - Transaction A]
-- Try to lock Seat 2 (Blocks and waits for Terminal 2 to release the lock)
SELECT * FROM Seats WHERE seat_id = 2 FOR UPDATE;

-- [Terminal 2 - Transaction B]
-- Try to lock Seat 1 (Blocks and waits for Terminal 1 to release the lock)
SELECT * FROM Seats WHERE seat_id = 1 FOR UPDATE;

-- RESULT: PostgreSQL detects the deadlock after a few moments and aborts one of the transactions automatically.
-- ERROR:  deadlock detected
-- DETAIL:  Process 12345 waits for ShareLock on transaction 6789; blocked by process 54321.

-- ---------------------------------------------------------
-- PART B: Strategy to Prevent Deadlocks
-- ---------------------------------------------------------
-- To prevent deadlocks, all transactions must always acquire locks in a predictable, consistent order.
-- For example, always lock rows in ascending order of their Primary Key (`seat_id`).

-- Safe approach (Transaction A and Transaction B both do this):
BEGIN;

-- Lock both seats simultaneously in a specific order (ascending seat_id)
SELECT * FROM Seats 
WHERE seat_id IN (1, 2) 
ORDER BY seat_id ASC
FOR UPDATE;

-- Update both seats safely without deadlock risk
UPDATE Seats SET status = 'BOOKED' WHERE seat_id IN (1, 2);

COMMIT;
