# FitZone Gym Management System

FitZone is a PostgreSQL-based gym management database designed to manage members, trainers, categories, classes, sessions, and bookings.

The project focuses on relational database design, data management, and database-side programming using SQL and PL/pgSQL.

## Features

- Relational database design with connected entities and foreign-key relationships
- Member, trainer, class, session, category, and booking management
- PL/pgSQL functions and stored procedures
- Control flow, loops, and RECORD variables
- Exception handling for database operations
- Booking validation and duplicate booking prevention
- Rating validation and business rules
- Automatic member loyalty-level updates
- Session seat availability calculation
- Audit logging for booking INSERT, UPDATE, and DELETE operations

## Database Structure

The system is built around six core tables:

- **Members** — stores member information, account status, and loyalty data
- **Trainers** — stores trainer information and mentor relationships
- **Categories** — organizes gym class categories
- **Classes** — stores available gym classes
- **Sessions** — represents scheduled class sessions and assigned trainers
- **Bookings** — connects members with sessions and stores ratings and feedback

An additional **audit_log** table is used to track changes made to bookings.

## Database Logic

The project includes database-side logic implemented with PL/pgSQL, including:

- Retrieving member information
- Calculating trainer average ratings
- Calculating member loyalty points
- Adding new bookings
- Updating member status
- Looking up members by email
- Validating ratings
- Applying loyalty bonuses
- Calculating available seats for sessions
- Handling database exceptions
- Preventing duplicate bookings
- Preventing ratings from being modified after submission
- Automatically updating loyalty levels
- Logging booking operations

## Technologies

- PostgreSQL
- SQL
- PL/pgSQL
- pgAdmin

## Project Structure

```text
FitZone-Gym-Management-System/
│
├── README.md
├── database/
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   └── 03_queries.sql
│
└── docs/
    └── database-diagram.png
```

## Database Relationships

The database uses primary and foreign keys to maintain relationships between members, trainers, categories, classes, sessions, and bookings.

Bookings connect members to scheduled sessions, while sessions connect classes with trainers. Classes are organized by category, and trainers can also have mentor relationships.

## Highlights

The project goes beyond basic CRUD operations by implementing business rules directly at the database level using PL/pgSQL functions, procedures, and triggers.

Key examples include preventing duplicate bookings, protecting submitted ratings from being changed, maintaining member loyalty levels, calculating session availability, and automatically recording booking changes in an audit log.
