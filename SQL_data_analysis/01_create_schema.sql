
-- SQL Script for Project
-- Target Database: PostgreSQL

-- =========================================
-- === Schema Creation ===
-- =========================================

DROP TABLE IF EXISTS viewing_log;
DROP TABLE IF EXISTS demographics;
DROP TABLE IF EXISTS events;

-- Create the 'events' table
CREATE TABLE events (
    event_id INT PRIMARY KEY,             -- Unique identifier for the event
    event_name VARCHAR(255) NOT NULL,     -- Name of the event (e.g., "EPL: Team A vs Team B")
    sport_category VARCHAR(50) NOT NULL,  -- Broad sport category (e.g., "Football", "Boxing")
    league VARCHAR(100),                  -- Specific league or competition (can be NULL)
    event_date DATE NOT NULL              -- Date the event took place
);
CREATE INDEX idx_events_sport_category ON events(sport_category);

-- Create the 'demographics' table 
CREATE TABLE demographics (
    user_id INT PRIMARY KEY,              -- Unique identifier for the user
    country VARCHAR(100),                 -- User's country
    age_group VARCHAR(20)                 -- User's age group (e.g., "25-34")
);
CREATE INDEX idx_demographics_country ON demographics(country);
CREATE INDEX idx_demographics_age_group ON demographics(age_group);

-- Create the 'viewing_log' table
CREATE TABLE viewing_log (
    log_id BIGSERIAL PRIMARY KEY,         -- Auto-incrementing unique ID for each log entry
    user_id INT NOT NULL,                 -- Identifier for the user who watched
    event_id INT NOT NULL,                -- Identifier for the event watched
    view_timestamp TIMESTAMP NOT NULL,    -- Exact time the viewing occurred
    duration_minutes INT NOT NULL,        -- How long the user watched (in minutes)

    -- Define Foreign Key constraints
    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES demographics(user_id)
        ON DELETE SET NULL, 
  
    CONSTRAINT fk_event
        FOREIGN KEY(event_id)
        REFERENCES events(event_id)
        ON DELETE CASCADE 
);

-- Add indexes for faster joins and filtering
CREATE INDEX idx_viewing_log_user_id ON viewing_log(user_id);
CREATE INDEX idx_viewing_log_event_id ON viewing_log(event_id);
CREATE INDEX idx_viewing_log_view_timestamp ON viewing_log(view_timestamp);
