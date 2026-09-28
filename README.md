# FitZone Gym Management System

FitZone is a PostgreSQL-based gym management database designed to support the workflow of a gym, from member registration and class scheduling to session bookings, ratings, and loyalty management.

The project started with relational database design and SQL fundamentals, then expanded into database-side programming with PL/pgSQL, stored procedures, triggers, exception handling, validation, and automated business rules.

## Database Design

The core database consists of six related tables:

- **members** — member information, contact details, address, status, and loyalty data
- **trainers** — trainer information with a self-referencing mentor relationship
- **categories** — gym class categories
- **classes** — classes assigned to categories
- **sessions** — scheduled class sessions led by trainers
- **bookings** — connects members to sessions and stores ratings and feedback

An additional **audit_log** table is used to track changes made to bookings.

## Database Schema

The following diagram shows the structure and relationships between the six core tables:

<img width="832" height="600" alt="fitzone_schema" src="https://github.com/user-attachments/assets/9071225e-6df2-427c-a648-e6068d91bb5c" />


## Key Features

### Relational Database Design
- Normalized relational schema
- Primary and foreign key relationships
- Self-referencing trainer/mentor relationship
- Many-to-many relationship between members and sessions through bookings
- Data integrity using `NOT NULL`, `UNIQUE`, `CHECK`, and `DEFAULT` constraints

### SQL & Data Management
- DDL and DML operations
- Data insertion and updates
- JOIN operations across related tables
- Aggregation and grouping
- Subqueries
- Database indexing
- User permissions using DCL
- Read-only and manager database roles

### PL/pgSQL
- Anonymous `DO` blocks
- Variables and `%TYPE`
- `SELECT INTO`
- Conditional logic with `IF / ELSIF / ELSE`
- `FOR` and `WHILE` loops
- RECORD variables
- Functions
- Stored procedures
- Exception handling
- Named PostgreSQL exceptions

### Functions & Procedures
The database includes reusable logic for:

- Retrieving member information
- Looking up members by email
- Calculating trainer average ratings
- Calculating member loyalty points
- Adding new bookings
- Updating member status
- Validating ratings
- Applying loyalty bonuses
- Calculating available seats for sessions

### Triggers & Business Rules
Database-level automation is used to:

- Prevent duplicate session bookings
- Prevent a submitted rating from being changed
- Automatically update member loyalty levels
- Keep loyalty levels within their allowed limit
- Track booking changes automatically

### Audit Logging
An `audit_log` table records changes to bookings, including:

- INSERT
- UPDATE
- DELETE

This provides a history of booking operations performed in the database.

## Technologies

- PostgreSQL
- SQL
- PL/pgSQL
- pgAdmin
- ERDPlus

## Concepts Applied

`Database Design` · `Normalization` · `ERD` · `DDL` · `DML` · `DCL` · `Joins` · `Aggregation` · `Subqueries` · `Indexes` · `Functions` · `Stored Procedures` · `Triggers` · `Exception Handling` · `Audit Logging` · `Business Rules`

## Project Structure

```text
FitZone-Gym-Management-System/
│
├── README.md
├── fitzone_database.sql
├── fitzone_plpgsql.sql
└── assets/
    └── fitzone_schema.png
```

## Project Highlights

FitZone demonstrates both relational database design and database-side programming. Beyond storing and querying data, the database enforces business rules, validates operations, handles errors, automates loyalty management, and maintains an audit trail for booking activity.
