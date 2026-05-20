-- ==============================================================================
-- Q1 & Q5. Database Design & Seed Data
-- ==============================================================================

-- Drop tables if they already exist to ensure a clean slate
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Seats;
DROP TABLE IF EXISTS Shows;
DROP TABLE IF EXISTS Users;

-- 1. Users Table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Shows (or Trips) Table
CREATE TABLE Shows (
    show_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    show_time TIMESTAMP NOT NULL,
    total_seats INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Seats Table
-- Includes 'version' for Q5 (Optimistic Locking)
CREATE TABLE Seats (
    seat_id SERIAL PRIMARY KEY,
    show_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    status VARCHAR(20) DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'BOOKED', 'LOCKED')),
    version INT DEFAULT 1, -- Added for Q5: Optimistic Locking
    locked_at TIMESTAMP,   -- Added for Q8: Bonus Challenge
    FOREIGN KEY (show_id) REFERENCES Shows(show_id) ON DELETE CASCADE,
    UNIQUE (show_id, seat_number) -- Prevent duplicate seats per show
);

-- 4. Bookings Table
CREATE TABLE Bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    seat_id INT NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'CONFIRMED' CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'FAILED')),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id) ON DELETE CASCADE
);

-- ==============================================================================
-- Insert Sample/Dummy Data
-- ==============================================================================

-- Insert Users
INSERT INTO Users (username, email) VALUES
('alice_smith', 'alice@example.com'),
('bob_jones', 'bob@example.com'),
('charlie_brown', 'charlie@example.com');

-- Insert Shows
INSERT INTO Shows (title, show_time, total_seats) VALUES
('Avengers: Endgame', '2026-06-01 18:30:00', 50),
('Interstellar', '2026-06-02 20:00:00', 50);

-- Insert Seats for Show 1 (Avengers)
INSERT INTO Seats (show_id, seat_number) VALUES
(1, 'A1'), (1, 'A2'), (1, 'A3'), (1, 'A4'), (1, 'A5');

-- Insert Seats for Show 2 (Interstellar)
INSERT INTO Seats (show_id, seat_number) VALUES
(2, 'B1'), (2, 'B2'), (2, 'B3'), (2, 'B4'), (2, 'B5');

-- Display setup success
SELECT 'Database schema created and seed data inserted successfully.' AS Status;
