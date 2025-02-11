--creating a new rdms for snakes
create database snake;

--using the databse snake
use snake;


--Note
--for most of the columns that has to store Strings,varchar is preferred as it occupies only that much space as needed.


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

--inserting values into species table

INSERT INTO Species (SpeciesID, CommonName, ScientificName, Habitat, Venomous)
VALUES
    (1, 'King Cobra', 'Ophiophagus hannah', 'Tropical and Subtropical Forests', 1),
    (2, 'Giant Anaconda', 'Eunectes murinus', 'River Floodplains and Wetlands', 0),
    (3, 'Black Mamba', 'Dendroaspis polylepis', 'Woodland and Savanna of Africa', 1),
    (4, 'Burmese Python', 'Python bivittatus', 'Rainforests and Grasslands of Southeast Asia', 0),
    (5, 'Indian Python', 'Python molurus', 'Tropical and Subtropical Regions of India', 0),
    (6, 'Reticulated Python', 'Python reticulatus', 'Southeast Asia', 0);

--inserting values into Snakes table
INSERT INTO Snakes (SnakeID, SpeciesID, Length, Age, Color)
VALUES
(1, 1, 5.0, 16, 'Light Brown with Yellowish Markings'),
(2, 1, 3.5, 9, 'Dark Green with Black Bands'),
(3, 2, 8.1, 25, 'Dark Green with Yellow Underbelly'),
(4, 3, 2.6, 4, 'Olive Green with Blackish Patterns'),
(5, 4, 4.5, 7, 'Brown and Yellow with a Pattern'),
(6, 5, 3.2, 10, 'Light Brown with Faint Black Spots'),
(7, 6, 6.0, 14, 'Goldish with Reticulated Patterns');



--inserting values into Sightings table
INSERT INTO Sightings (SightingID, SnakeID, Location, SightingDate, Observer)
VALUES
(1, 1, 'Southern Thailand', '2024-06-10', 'John Doe'),
(2, 2, 'Amazon Basin, Brazil', '2024-03-15', 'Sarah Smith'),
(3, 3, 'Kruger National Park, South Africa', '2024-01-20', 'Mike Johnson'),
(4, 4, 'Myanmar, Southeast Asia', '2024-02-25', 'Emily Clark'),
(5, 5, 'Central India', '2024-05-08', 'David Brown'),
(6, 6, 'Borneo, Malaysia', '2024-07-11', 'Olivia Davis');

INSERT INTO Sightings (SightingID, SnakeID, Location, SightingDate, Observer)
VALUES (7, 7, 'Thailand', '2015-05-24', 'Sarah Smith');

INSERT INTO Sightings (SightingID, SnakeID, Location, SightingDate, Observer)
VALUES (8, 4, 'Thailand', '2015-05-29', 'Sarah Smith'),(9,4,'Bhutan','2016-07-30','John Doe'),(10,4,'Nepal','2016-07-21','Richie'),(11,4,'Thailand','2016-07-21','Roe Doe'),(12,4,'India','2016-07-29','hoe doe'),(13,4,'Nepal','2016-07-21','haha'),(14,4,'Nepal','2016-07-11','tata'),(15,4,'Thailand','2046-07-27','baba'),(16,4,'Singapore','2016-07-21','gullla'),(17,4,'Thailand','2016-07-02','Tic Tac'),(18,4,'Nepal','2016-07-26','titi'),(19,4,'Thailand','2021-07-21','abhi singh');

INSERT INTO Sightings (SightingID, SnakeID, Location, SightingDate, Observer)
VALUES (20, 3, 'Thailand', '2015-05-29', 'Sarah Smith'),(21,3,'Bhutan','2016-07-30','John Doe'),(22,3,'Nepal','2016-07-21','Richie'),(23,3,'Thailand','2016-07-21','Roe Doe'),(24,3,'India','2016-07-29','hoe doe'),(25,3,'Nepal','2016-07-21','haha'),(26,3,'Nepal','2016-07-11','tata'),(27,3,'Thailand','2046-07-27','baba'),(28,3,'Singapore','2016-07-21','gullla'),(29,3,'Thailand','2016-07-02','Tic Tac'),(30,3,'Nepal','2016-07-26','titi'),(31,3,'Thailand','2021-07-21','abhi singh');


--inserting values into ConservationStatus table

INSERT INTO ConservationStatus (StatusID, SpeciesID, Status, LastUpdated)
VALUES
(1, 1, 'Critically Endangered', GETDATE()),  
(2, 2, 'Least Concern', GETDATE()),          
(3, 3, 'Endangered', GETDATE()),              
(4, 4, 'Near Threatened', GETDATE()),         
(5, 5, 'Vulnerable', GETDATE()),              
(6, 6, 'Least Concern', GETDATE());          

ALTER TABLE ConservationStatus
ADD No_Of_TIMES_Status_changed INT DEFAULT 0;


--creating a trigger on ConservationStatus table because the lastupdated column has to get updated everytime status is changed.


CREATE TRIGGER trg_UpdateLastUpdated
ON ConservationStatus
AFTER UPDATE
AS
BEGIN
    
    IF UPDATE(Status)
    BEGIN
       
        UPDATE ConservationStatus
        SET LastUpdated = GETDATE(),
            No_Of_TIMES_Status_changed = No_Of_TIMES_Status_changed + 1
        WHERE StatusID IN (SELECT StatusID FROM inserted);  
END;

--Q1 Retrieve all sightings of a specific species by common name.
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
    sp.CommonName in (select CommonName from Species);


--Q2 Find the average length of snakes by species.

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

  with temp_table as(
  select sh.Observer,count(s.SpeciesID) as SightedCount
  from Snakes s 
  join Sightings sh 
  on s.SnakeID=sh.SnakeID 
  group by sh.Observer)
  select * from temp_table
  where SightedCount=(select max(SightedCount) from temp_table);
 
 --Q5  Determine the change in conservation status for species over time.

 --for this question lets try to modify the status field in ConservationStatusTable

 select *from ConservationStatus;

 update ConservationStatus
 set Status='Endangered' where StatusId=1;

  update ConservationStatus
 set Status='Vulnerable' where StatusId=2;

  update ConservationStatus
 set Status='Protected' where StatusId=1;

-- ans->
 select s.SpeciesID,c.LastUpdated,c.Status as 'Current Status',s.CommonName,c.No_Of_TIMES_Status_changed AS 'ChangeInStatus(in no of times)' 
 from Species s join ConservationStatus c
 on s.SpeciesID=c.SpeciesID;



 --Q6 List species that are classified as "Endangered" and have been sighted more than 10 times.
  WITH cte_endangered AS (
    SELECT s.SpeciesID,sh.Observer, COUNT(s.SpeciesID) AS SightedCount
    FROM Snakes s 
    JOIN Sightings sh ON s.SnakeID = sh.SnakeID
    WHERE s.SpeciesID IN (SELECT SpeciesID FROM ConservationStatus WHERE Status = 'Endangered')
    GROUP BY sh.Observer, s.SpeciesID
)
SELECT SpeciesID,Observer
FROM cte_endangered
WHERE SightedCount >= 10;


