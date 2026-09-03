# RaceDay

RaceDay is a full-stack, API-driven event management system built for the South African road running, walking, and cycling community. Event Organisers can create and manage events, categories, and participant results. Participants can browse events, enter categories, track their enrolments, and view their personal results.

This project is being built progressively across three parts for PROG6212 (Portfolio of Evidence). This README will be updated as each part is completed.

---

## Part 1 - System Planning and Database

Before any application code was written, the system was planned in full. All planning documents live in the `/docs` folder of this repository.

### What's in `/docs`

- `raceday_erd.docx` - Entity Relationship Diagram (Section A), built with native Word shapes using UML class notation
- `RaceDay_API_Endpoint_Plan.md` - Full API endpoint plan (Section B), listing every route the system will expose along with method, role, request body, and expected response
- `RaceDay_Database.sql` - SQL script (Section C), creates the full database schema and seeds it with sample data

### Entity Relationship Diagram

The database is modelled around 6 entities:

- **Users** - stores both Organisers and Participants, distinguished by a `Role` column
- **Events** - created by an Organiser
- **Categories** - each Event has multiple categories (e.g. 5km, 10km, 21km)
- **Enrolments** - a Participant enters an Event by selecting a Category
- **Results** - one optional result per Enrolment, captured by an Organiser
- **Payments** - one optional payment per Enrolment

Relationships:

- Users to Events: 1 to 0..* (an Organiser creates many Events)
- Events to Categories: 1 to 0..* (an Event has many Categories)
- Users to Enrolments: 1 to 0..* (a Participant makes many Enrolments)
- Categories to Enrolments: 1 to 0..* (a Category receives many Enrolments)
- Enrolments to Results: 1 to 0..1 (an Enrolment may have one Result)
- Enrolments to Payments: 1 to 0..1 (an Enrolment may have one Payment)

The ERD matches the SQL script exactly - same table names, same primary and foreign keys.

### API Endpoint Plan

The API plan covers all required functional areas: Authentication, User Profile, Events, Categories, Event Enrolments, and Results. Every endpoint is documented with its HTTP method, route, description, required role, request body, and expected response codes. See [`docs/RaceDay_API_Endpoint_Plan.md`](docs/RaceDay_API_Endpoint_Plan.md) for the full plan.

Role-based access is planned at the API level (enforced in Part 2) and will be reflected consistently in the MVC interface in Part 3.

### Database Script

The SQL script (`docs/RaceDay_Database.sql`) was written for SQL Server Management Studio (SSMS) and:

- Creates the `RaceDayDB` database from a clean instance
- Creates all 6 tables with primary keys, foreign keys, and constraints (`NOT NULL`, `UNIQUE`, `DEFAULT`, `CHECK`)
- Seeds the database with realistic sample data: 2 Organisers and 2 Participants, 3 Events (Cape Town Cycle Tour, Soweto Marathon, Gqeberha Park Run Challenge), multiple categories per event, and sample enrolments, payments, and results

**To run it:** open the script in SQL Server Management Studio, connect to a local or clean SQL Server instance, and execute. The script drops and recreates `RaceDayDB` if it already exists, so it can be run repeatedly during testing.

### Notes / Assumptions

- Users are stored in a single table with a `Role` column (`Organiser` or `Participant`) rather than two separate tables, which still satisfies the two-role requirement while keeping authentication simpler in Part 2.
- A `Payments` entity was added beyond the minimum requirement, since real event entries involve an entry fee - this reflects a realistic system rather than a stripped-down version.
- No API code has been written in this part, in line with the brief.

- youtube video
- https://youtu.be/s6STfW2xpDw
CI screenshot

<img width="958" height="251" alt="Screenshot 2026-09-03 220022" src="https://github.com/user-attachments/assets/1c67e1c4-550d-4421-bad6-9aa27a22b79f" />

- i used my phone when recording for the video so please use a phone when you watch it because it will be blurry a little on a pc





