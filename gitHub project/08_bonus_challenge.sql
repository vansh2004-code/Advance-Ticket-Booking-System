-- ==============================================================================
-- Q8. Bonus Challenge (Very Tough)
-- ==============================================================================
-- Problem: Design a mechanism to:
-- • Auto-release locked seats after timeout
-- • Maintain a waiting queue for fully booked shows

-- ---------------------------------------------------------
-- PART A: Auto-release locked seats after timeout
-- ---------------------------------------------------------
-- When a user begins the checkout process, we set the seat to 'LOCKED' and log the time.
-- Note: 'locked_at' column was added in 01_schema_and_seed.sql.

-- 1. User locks the seat for payment (valid for 5 minutes)
UPDATE Seats 
SET status = 'LOCKED', locked_at = CURRENT_TIMESTAMP
WHERE seat_id = 8 AND status = 'AVAILABLE';

-- 2. Background Job Query to release expired locks
-- A system like pg_cron, or a background worker in the application (NodeJS/Java/Python),
-- would run this query every minute to free up seats that timed out.
UPDATE Seats
SET status = 'AVAILABLE', locked_at = NULL
WHERE status = 'LOCKED' 
  AND locked_at < CURRENT_TIMESTAMP - INTERVAL '5 minutes';
  
-- ---------------------------------------------------------
-- PART B: Maintain a waiting queue for fully booked shows
-- ---------------------------------------------------------
-- We can create a Waitlist table. 

CREATE TABLE IF NOT EXISTS Waitlist (
    waitlist_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    show_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'WAITING',
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

-- When a user tries to book but the show is full, insert them into the waitlist.
-- E.g., User 2 wants to see Show 1 but it's full.
INSERT INTO Waitlist (user_id, show_id) VALUES (2, 1);
INSERT INTO Waitlist (user_id, show_id) VALUES (3, 1);

-- 3. Trigger / Logic for when a seat becomes available (e.g. Booking Cancelled)
-- If User 1 cancels their booking, we change the seat to AVAILABLE, but wait! We have a waitlist.

BEGIN;

-- User 1 cancels booking on seat 1
UPDATE Bookings SET status = 'CANCELLED' WHERE user_id = 1 AND seat_id = 1;

-- Check if anyone is in the waitlist for this show
-- We use FOR UPDATE SKIP LOCKED to ensure multiple concurrent cancellations 
-- don't pop the same person off the waitlist.
WITH NextInLine AS (
    SELECT waitlist_id, user_id 
    FROM Waitlist 
    WHERE show_id = 1 AND status = 'WAITING' 
    ORDER BY joined_at ASC 
    LIMIT 1 
    FOR UPDATE SKIP LOCKED
)
-- If someone is in the waitlist, assign the seat to them (Set status to LOCKED so they can pay)
UPDATE Seats 
SET status = 'LOCKED', locked_at = CURRENT_TIMESTAMP
WHERE seat_id = 1 AND EXISTS (SELECT 1 FROM NextInLine);

-- And mark the waitlist entry as NOTIFIED
UPDATE Waitlist 
SET status = 'NOTIFIED' 
WHERE waitlist_id IN (
    SELECT waitlist_id FROM Waitlist 
    WHERE show_id = 1 AND status = 'WAITING' 
    ORDER BY joined_at ASC 
    LIMIT 1 
    FOR UPDATE SKIP LOCKED
);

COMMIT;

-- Now the application can email the user: "A seat is available! You have 5 minutes to pay."
