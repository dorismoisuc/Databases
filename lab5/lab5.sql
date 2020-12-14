CREATE TABLE Spectator
(
	SpectatorId INT PRIMARY KEY IDENTITY(1,1),
	Ticket INT UNIQUE, 
	Price INT 
)

CREATE TABLE Spot
(
	SpotId INT PRIMARY KEY IDENTITY(1,1),
	RowNr INT,
	ColumnNr INT
)

CREATE TABLE Ticket
(
	TicketId INT PRIMARY KEY IDENTITY(1,1),
	SpectatorId INT REFERENCES Spectator(SpectatorId),
	SpotId INT REFERENCES Spot(SpotId)
)

GO
CREATE OR ALTER PROCEDURE insert_rows @tableName VARCHAR(50)
AS
	DECLARE @seed INT;
	DECLARE @query VARCHAR(200);
	SET @seed = IDENT_CURRENT(@tableName) + 1 
	SET @query = 'INSERT INTO ' + @tableName + ' VALUES(' + CONVERT(VARCHAR,@seed) + ',' + CONVERT(VARCHAR,@seed) + ')'
	EXEC (@query)
	SET @seed=(SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY])
GO 

DBCC CHECKIDENT('Spectator',RESEED,0)
DBCC CHECKIDENT('Spot',RESEED,0)
DBCC CHECKIDENT('Ticket',RESEED,0)

DELETE FROM Spectator
DELETE FROM Spot
DELETE FROM Ticket

SELECT * FROM Spectator
SELECT * FROM Spot
SELECT * FROM Ticket

DECLARE @rows INT
SET @rows = 1000
WHILE @rows > 0 
	BEGIN
			EXEC insert_rows 'Spectator'
			EXEC insert_rows 'Spot'
			EXEC insert_rows 'Ticket'
			SET @rows=@rows-1
	END

-- a
-- 1 clustered index scan
SELECT Spectator.SpectatorId FROM Spectator WHERE Spectator.Price = 7 

-- 1 clustered index seek
SELECT * FROM Spectator WHERE Spectator.SpectatorId BETWEEN 1 and 7

-- 1 nonclustered index scan
SELECT Spectator.Ticket FROM Spectator

-- 1 nonclustered index seek
SELECT Spectator.Ticket FROM Spectator WHERE Spectator.Ticket = 5

-- 1 key lookup and nonclustered index seek 
SELECT * FROM Spectator WHERE Spectator.Ticket = 3 

-- b 
-- Write a query on table Tb with a WHERE clause of the form WHERE
-- b2 = value and analyze its execution plan. Create a nonclustered index that can speed up the query. 
-- Examine the execution plan again.

IF EXISTS(SELECT * FROM sys.indexes WHERE name='index_RowNr')
DROP INDEX index_RowNr ON Spot
SELECT Spot.SpotId FROM Spot WHERE Spot.RowNr = 5 -- clustered Index scan

CREATE NONCLUSTERED INDEX index_RowNr ON Spot(RowNr)
SELECT Spot.SpotId FROM Spot WHERE Spot.RowNr = 5

-- c 
-- Create a view that joins at least 2 tables.
-- Check whether existing indexes are helpful; if not, reassess 
-- existing indexes / examine the cardinality of the tables.

GO
CREATE OR ALTER VIEW viewTest
AS 
	SELECT t.TicketId
	FROM Ticket t INNER JOIN Spectator s ON t.SpectatorId = s.SpectatorId
	WHERE t.SpectatorId between 50 and 100
GO

SELECT * FROM viewTest -- clustered scan/ seek 

DROP INDEX nonClusteredIndex ON Ticket
CREATE NONCLUSTERED INDEX nonClusteredIndex ON Ticket(SpectatorId)
SELECT * FROM viewTest -- nonclustered scan/ seek 