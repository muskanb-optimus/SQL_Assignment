--creating a new rdms for snakes

create database snake;

--using the databse snake

use snake;

--Species table
create table Species(
SpeciesID int Primary key,
CommonName varchar(30) not null,
ScientificName varchar(20) not null,
Habitat varchar(50) not null,
Venomous bit not null
);

ALTER TABLE Species
ALTER COLUMN ScientificName VARCHAR(40);


--Snakes table
create table Snakes(
SnakeID Int primary key,
SpeciesID int foreign key references Species(SpeciesID),
Length	decimal(4,3),
Age int,
Color varchar(20));

ALTER TABLE Snakes
ALTER COLUMN Color VARCHAR(100);


--Sightings table
create table Sightings(
SightingID int primary key not null,
SnakeID int foreign key references Snakes(SnakeID),
Location varchar(255) not null,
SightingDate date not  null,
Observer varchar(30) not null);




ALTER TABLE Sightings
ALTER COLUMN Observe VARCHAR(255);

--Conservation status table
create table ConservationStatus(
StatusID int primary key,
SpeciesID int foreign key references Species(SpeciesID),
Status varchar(255) not null,
LastUpdated date not null
);

--inserting values into spoecies table

INSERT INTO Species (SpeciesID, CommonName, ScientificName, Habitat, Venomous)
VALUES
    (1, 'King Cobra', 'Ophiophagus hannah', 'Tropical and Subtropical Forests', 1),
    (2, 'Giant Anaconda', 'Eunectes murinus', 'River Floodplains and Wetlands', 0),
    (3, 'Black Mamba', 'Dendroaspis polylepis', 'Woodland and Savanna of Africa', 1),
    (4, 'Burmese Python', 'Python bivittatus', 'Rainforests and Grasslands of Southeast Asia', 0),
    (5, 'Indian Python', 'Python molurus', 'Tropical and Subtropical Regions of India', 0),
    (6, 'Reticulated Python', 'Python reticulatus', 'Southeast Asia', 0);


INSERT INTO Snakes (SnakeID, SpeciesID, Length, Age, Color)
VALUES
(1, 1, 5.0, 16, 'Light Brown with Yellowish Markings'),
(2, 1, 3.5, 9, 'Dark Green with Black Bands'),
(3, 2, 8.1, 25, 'Dark Green with Yellow Underbelly'),
(4, 3, 2.6, 4, 'Olive Green with Blackish Patterns'),
(5, 4, 4.5, 7, 'Brown and Yellow with a Pattern'),
(6, 5, 3.2, 10, 'Light Brown with Faint Black Spots'),
(7, 6, 6.0, 14, 'Goldish with Reticulated Patterns');


drop table Sightings;

INSERT INTO Sightings (SightingID, SnakeID, Location, SightingDate, Observer)
VALUES
(1, 1, 'Southern Thailand', '2024-06-10', 'John Doe'),
(2, 2, 'Amazon Basin, Brazil', '2024-03-15', 'Sarah Smith'),
(3, 3, 'Kruger National Park, South Africa', '2024-01-20', 'Mike Johnson'),
(4, 4, 'Myanmar, Southeast Asia', '2024-02-25', 'Emily Clark'),
(5, 5, 'Central India', '2024-05-08', 'David Brown'),
(6, 6, 'Borneo, Malaysia', '2024-07-11', 'Olivia Davis');


INSERT INTO ConservationStatus (StatusID, SpeciesID, Status, LastUpdated)
VALUES
(1, 1, 'Critically Endangered', GETDATE()),  
(2, 2, 'Least Concern', GETDATE()),          
(3, 3, 'Endangered', GETDATE()),              
(4, 4, 'Near Threatened', GETDATE()),         
(5, 5, 'Vulnerable', GETDATE()),              
(6, 6, 'Least Concern', GETDATE());          


--creating a trigger on ConservationStatus table because the lastupdated column has to get updated everytime status is changed.

CREATE TRIGGER trg_UpdateLastUpdated
ON ConservationStatus
AFTER UPDATE
AS
BEGIN
   
    IF UPDATE(Status)
    BEGIN
        
        UPDATE ConservationStatus
        SET LastUpdated = GETDATE()
        WHERE StatusID IN (SELECT StatusID FROM inserted);
    END
END;

--Q1 
SELECT 
    sp.SpeciesID,
	 sp.CommonName,
    s.SightingID,
    s.SnakeID,
    s.Location,
    s.SightingDate,
    s.Observer
  
FROM 
    Sightings s
JOIN 
    Snakes sn ON s.SnakeID = sn.SnakeID
JOIN 
    Species sp ON sn.SpeciesID = sp.SpeciesID
WHERE 
    sp.CommonName = 'King Cobra';


	--q2

	select SpeciesId,avg(Length) as AvgLength
	from Snakes 
	group by SpeciesID;

	--Q3 Find the top 5 longest snakes for each species.

	select * from Snakes;
WITH snake_cte AS (
    SELECT 
        SpeciesID, 
        SnakeID, 
        Length,
        ROW_NUMBER() OVER (PARTITION BY SpeciesID ORDER BY Length DESC) AS RowNum
    FROM Snakes
)
SELECT SpeciesID, SnakeID, Length
FROM snake_cte
WHERE RowNum <= 5;

--Q4 Identify the observer who has seen the highest number of different species.


select * from Snakes,Species,Sightings,ConservationStatus;



