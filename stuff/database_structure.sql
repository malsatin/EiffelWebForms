--
-- File generated with SQLiteStudio v3.1.1 on ¬т апр 11 01:50:40 2017
--
-- Text encoding used: System
--
PRAGMA foreign_keys = off;
BEGIN TRANSACTION;

-- Table: admins
CREATE TABLE admins (id INTEGER PRIMARY KEY ON CONFLICT REPLACE AUTOINCREMENT, name VARCHAR (32) UNIQUE ON CONFLICT FAIL, password VARCHAR (64));

-- Table: reports
CREATE TABLE reports (id INTEGER PRIMARY KEY ON CONFLICT REPLACE AUTOINCREMENT, unit_name TEXT, unit_head TEXT, publications TEXT, supervised_students_number INTEGER, research_collaborations_number INTEGER, patents TEXT, students_reports TEXT, all_data TEXT, date_from VARCHAR (19), date_to VARCHAR (19));

-- Table: sessions
CREATE TABLE sessions (id VARCHAR (32) PRIMARY KEY, data TEXT, update_time INTEGER);

-- Index: admins_index
CREATE UNIQUE INDEX admins_index ON admins (id);

-- Index: report_unit_name
CREATE INDEX report_unit_name ON reports (unit_name);

-- Index: reports_index
CREATE UNIQUE INDEX reports_index ON reports (id);

-- Index: session_index
CREATE UNIQUE INDEX session_index ON sessions (id);

COMMIT TRANSACTION;
PRAGMA foreign_keys = on;
