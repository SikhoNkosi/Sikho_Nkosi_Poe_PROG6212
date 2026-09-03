/* ============================================================
   RaceDay Database Script
   PROG6212 - Portfolio of Evidence - Part 1, Section C
   Run in SQL Server Management Studio (SSMS) on a clean instance
   ============================================================ */

IF DB_ID('RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

/* ============================================================
   TABLE: Users
   Stores both Organisers and Participants, distinguished by Role
   ============================================================ */
CREATE TABLE Users (
    UserId          INT IDENTITY(1,1) PRIMARY KEY,
    FullName        NVARCHAR(100)   NOT NULL,
    Email           NVARCHAR(150)   NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(255)   NOT NULL,
    Role            NVARCHAR(20)    NOT NULL
                        CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser','Participant')),
    PhoneNumber     NVARCHAR(20)    NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

/* ============================================================
   TABLE: Events
   Each event is created by exactly one Organiser
   ============================================================ */
CREATE TABLE Events (
    EventId         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId     INT             NOT NULL,
    EventName       NVARCHAR(150)   NOT NULL,
    Description     NVARCHAR(MAX)   NULL,
    EventDate       DATE            NOT NULL,
    Location        NVARCHAR(150)   NOT NULL,
    Province        NVARCHAR(50)    NULL,
    RouteMapUrl     NVARCHAR(255)   NULL,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId)
        REFERENCES Users(UserId)
);
GO

/* ============================================================
   TABLE: Categories
   Each Event can have many Categories (e.g. 5km, 10km, 21km)
   ============================================================ */
CREATE TABLE Categories (
    CategoryId      INT IDENTITY(1,1) PRIMARY KEY,
    EventId         INT             NOT NULL,
    CategoryName    NVARCHAR(100)   NOT NULL,
    DistanceKm      DECIMAL(5,2)    NOT NULL,
    EntryFee        DECIMAL(8,2)    NOT NULL DEFAULT 0,
    MaxParticipants INT             NOT NULL DEFAULT 100,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId)
        REFERENCES Events(EventId) ON DELETE CASCADE
);
GO

/* ============================================================
   TABLE: Enrolments
   A Participant enters an Event by selecting a Category
   ============================================================ */
CREATE TABLE Enrolments (
    EnrolmentId     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId   INT             NOT NULL,
    CategoryId      INT             NOT NULL,
    EnrolmentDate   DATETIME        NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Confirmed'
                        CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Confirmed','Cancelled','Pending')),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantId)
        REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryId)
        REFERENCES Categories(CategoryId),
    CONSTRAINT UQ_Enrolments_Participant_Category UNIQUE (ParticipantId, CategoryId)
);
GO

/* ============================================================
   TABLE: Results
   One result per Enrolment, captured by an Organiser
   ============================================================ */
CREATE TABLE Results (
    ResultId                INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId             INT             NOT NULL UNIQUE,
    CapturedByOrganiserId   INT             NOT NULL,
    FinishTime              TIME            NULL,
    Position                INT             NULL,
    CapturedDate            DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId)
        REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE,
    CONSTRAINT FK_Results_Users FOREIGN KEY (CapturedByOrganiserId)
        REFERENCES Users(UserId)
);
GO

/* ============================================================
   TABLE: Payments
   One payment per Enrolment
   ============================================================ */
CREATE TABLE Payments (
    PaymentId       INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId     INT             NOT NULL UNIQUE,
    Amount          DECIMAL(8,2)    NOT NULL,
    PaymentMethod   NVARCHAR(30)    NOT NULL DEFAULT 'Card',
    PaymentStatus   NVARCHAR(20)    NOT NULL DEFAULT 'Paid'
                        CONSTRAINT CK_Payments_Status CHECK (PaymentStatus IN ('Paid','Pending','Failed')),
    PaymentDate     DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Payments_Enrolments FOREIGN KEY (EnrolmentId)
        REFERENCES Enrolments(EnrolmentId) ON DELETE CASCADE
);
GO


/* ============================================================
   SEED DATA
   ============================================================ */

-- Organisers (2)
INSERT INTO Users (FullName, Email, PasswordHash, Role, PhoneNumber) VALUES
('Thandeka Mokoena', 'thandeka@raceday.co.za', 'HASHED_PWD_1', 'Organiser', '0821234567'),
('Johan van der Merwe', 'johan@raceday.co.za', 'HASHED_PWD_2', 'Organiser', '0837654321');

-- Participants (2)
INSERT INTO Users (FullName, Email, PasswordHash, Role, PhoneNumber) VALUES
('Sikho Dlamini', 'sikho@example.com', 'HASHED_PWD_3', 'Participant', '0721112222'),
('Amahle Nkosi', 'amahle@example.com', 'HASHED_PWD_4', 'Participant', '0733334444');

-- Events (3)
INSERT INTO Events (OrganiserId, EventName, Description, EventDate, Location, Province, RouteMapUrl) VALUES
(1, 'Cape Town Cycle Tour', 'Iconic road cycling event around the Cape Peninsula.', '2026-03-08', 'Cape Town', 'Western Cape', 'https://raceday.co.za/routes/ctct'),
(1, 'Soweto Marathon', 'Community road running event through Soweto.', '2026-11-01', 'Soweto', 'Gauteng', 'https://raceday.co.za/routes/soweto'),
(2, 'Gqeberha Park Run Challenge', 'Weekend park run series for all fitness levels.', '2026-05-16', 'Gqeberha', 'Eastern Cape', 'https://raceday.co.za/routes/gqeberha');

-- Categories (for each event)
INSERT INTO Categories (EventId, CategoryName, DistanceKm, EntryFee, MaxParticipants) VALUES
(1, '109km Cycle Tour', 109.00, 550.00, 5000),
(1, '43km Cycle Tour', 43.00, 350.00, 2000),
(2, '42.2km Full Marathon', 42.20, 300.00, 3000),
(2, '21.1km Half Marathon', 21.10, 200.00, 3000),
(3, '10km Park Run', 10.00, 100.00, 500),
(3, '5km Fun Run', 5.00, 50.00, 500);

-- Enrolments (sample)
INSERT INTO Enrolments (ParticipantId, CategoryId, Status) VALUES
(3, 1, 'Confirmed'),
(3, 5, 'Confirmed'),
(4, 3, 'Confirmed'),
(4, 6, 'Confirmed');

-- Payments (matching enrolments)
INSERT INTO Payments (EnrolmentId, Amount, PaymentMethod, PaymentStatus) VALUES
(1, 550.00, 'Card', 'Paid'),
(2, 100.00, 'Card', 'Paid'),
(3, 300.00, 'EFT', 'Paid'),
(4, 50.00, 'Card', 'Paid');

-- Results (sample, for two completed enrolments)
INSERT INTO Results (EnrolmentId, CapturedByOrganiserId, FinishTime, Position) VALUES
(2, 2, '00:52:14', 12),
(4, 2, '00:24:03', 5);
GO

/* ============================================================
   Quick verification queries (optional - comment out before submission
   if your rubric wants a "clean" script with only DDL/DML)
   ============================================================ */
-- SELECT * FROM Users;
-- SELECT * FROM Events;
-- SELECT * FROM Categories;
-- SELECT * FROM Enrolments;
-- SELECT * FROM Results;
-- SELECT * FROM Payments;
