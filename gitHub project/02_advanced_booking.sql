-- ==============================================================================
-- Q2. Advanced Booking Transaction
-- ==============================================================================
-- Problem: Write a transaction-safe booking procedure that:
-- • Locks the selected seat using FOR UPDATE NOWAIT
-- • Checks availability
-- • Updates seat status
-- • Inserts booking record
-- • Uses COMMIT / ROLLBACK on failure

-- Using PostgreSQL PL/pgSQL for the procedure logic.
-- Note: In standard SQL scripting without PL/pgSQL, this would just be a BEGIN...COMMIT block.
-- Here we simulate the process with a plpgsql block for proper error handling.

DO $$
DECLARE
    v_seat_id INT := 1; -- Example: Attempting to book seat 'A1' (seat_id = 1)
    v_user_id INT := 1; -- Example: Booking for 'alice_smith'
    v_seat_status VARCHAR;
BEGIN
    -- Start Transaction Block
    -- In DO blocks, we are already inside a transaction.

    -- Step 1: Attempt to lock the seat without waiting (NOWAIT)
    RAISE NOTICE 'Attempting to lock seat % for booking...', v_seat_id;
    
    SELECT status INTO v_seat_status 
    FROM Seats 
    WHERE seat_id = v_seat_id 
    FOR UPDATE NOWAIT; -- Lock the row immediately or throw an error if already locked by someone else

    -- Step 2: Check Availability
    IF v_seat_status = 'AVAILABLE' THEN
        -- Step 3: Update seat status to BOOKED
        UPDATE Seats 
        SET status = 'BOOKED' 
        WHERE seat_id = v_seat_id;

        -- Step 4: Insert booking record
        INSERT INTO Bookings (user_id, seat_id, status)
        VALUES (v_user_id, v_seat_id, 'CONFIRMED');

        RAISE NOTICE 'Booking successful for seat % by user %.', v_seat_id, v_user_id;
        
        -- The block completes successfully, which acts as an implicit COMMIT.
    ELSE
        RAISE NOTICE 'Seat % is no longer available (Status: %). Rolling back...', v_seat_id, v_seat_status;
        -- Step 5: Rollback on failure (Availability check failed)
        -- We can force a rollback in PL/pgSQL by raising an exception, or we can just let it finish without updating.
        -- Let's raise an exception to explicitly abort the transaction.
        RAISE EXCEPTION 'Seat unavailable. Transaction aborted.';
    END IF;

EXCEPTION
    WHEN lock_not_available THEN
        -- Step 5: Handle the NOWAIT failure
        -- If another user is currently locking the row, PostgreSQL throws 'lock_not_available' (55P03)
        RAISE NOTICE 'Seat % is currently being booked by someone else (Locked). Transaction aborted.', v_seat_id;
        -- Implicit ROLLBACK happens here
    WHEN OTHERS THEN
        -- Catch the custom exception or any other errors
        RAISE NOTICE 'Error occurred: %. Transaction aborted.', SQLERRM;
        -- Implicit ROLLBACK happens here
END $$;
