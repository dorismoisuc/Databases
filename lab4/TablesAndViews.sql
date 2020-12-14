-- get all the players' id that are sponsored by Uniqlo or Lacoste
-- a view with a SELECT statement operating on one table
CREATE VIEW Select1 AS 
	SELECT PlayerID
	FROM SponsorPlayer
	WHERE SponsorID in (90,900)
GO 

-- find the name of the players that are Sponsored by Nike
-- a view with a SELECT statement operating on at least 2 tables
CREATE VIEW Select2 AS 
	SELECT Player1.Name
	FROM Player Player1
	WHERE Player1.PlayerID IN
		(SELECT Sponsored.PlayerID
		FROM SponsorPlayer Sponsored
		WHERE Sponsored.SponsorID=909)
GO

-- get all the Player Rankings which have a ranking more than average
-- a view with a SELECT statement that has a GROUP BY clause and operates on at least 2 tables
CREATE VIEW Select3 AS
	SELECT P.RankingID
	FROM Player P
	GROUP BY P.RankingID
	HAVING P.RankingID > 
		(
			SELECT AVG(R.RankingID) AverageRank
			FROM Ranking R
		)
GO

-- a table with a single-column primary key and no foreign keys
-- Ranking Table 1PK

-- a table with a single-column primary key and at least one foreign key;
-- Player Table 1PK, 2 FK 

-- a table with a multicolumn primary key,
-- RGTitle, 2 PK

-- ALTER TABLE RGTitle
-- DROP CONSTRAINT TitleID

ALTER TABLE RGTitle
ADD NumberOfTitles INT NOT NULL CONSTRAINT nr DEFAULT 0

ALTER TABLE RGTitle
DROP COLUMN NumberOfTitles

ALTER TABLE RGTitle
ADD CONSTRAINT NumberOfTitles PRIMARY KEY(NumberOfTitles, TitleID) 


-- deleting the content 

DELETE FROM Ballkids
DBCC CheckIdent('Ballkids',RESEED,0) 

DELETE FROM PlayerGame

DELETE FROM SponsorPlayer

DELETE FROM RGTitle

DELETE FROM Player

DELETE FROM Game

DELETE FROM Referee

DELETE FROM Arena

DELETE FROM Sponsor

DELETE FROM Ranking

-- checking if they are empty

SELECT * FROM Ballkids
SELECT * FROM PlayerGame
SELECT * FROM SponsorPlayer
SELECT * FROM Player
SELECT * FROM Game
SELECT * FROM Referee
SELECT * FROM Arena
SELECT * FROM Sponsor
SELECT * FROM Ranking
SELECT * FROM RGTitle



GO
CREATE OR ALTER PROCEDURE clear_table @tableName VARCHAR(50)
AS
    DECLARE @query VARCHAR(50)
    SET @query = 'DELETE FROM ' + @tableName
    EXEC (@query)

ALTER TABLE RGTitle
DROP CONSTRAINT PlayerID

ALTER TABLE RGTitle
DROP COLUMN PlayerID

ALTER TABLE RGTitle
ADD PlayerID int REFERENCES Player(PlayerID)  

-- generate a random float nubmer between [0,1) and add it in a view
GO
CREATE VIEW rand_view
AS
	SELECT RAND() AS Value
GO

-- generate a random integer between [left, right] 
CREATE FUNCTION generate_random_integer(
		@left INT,
		@right INT
)
	RETURNS INT AS
		BEGIN
			RETURN FLOOR((SELECT Value FROM rand_view)*(@right-@left) + @left)
		END
GO 


-- tables : Ranking, RGTitle, Player
-- insert a test entry into Ranking
CREATE OR ALTER PROCEDURE insert_Ranking @seed INT
	AS
		BEGIN
			INSERT Ranking(RankingID,NumberOfPlayers)
				VALUES
				(@seed,[dbo].[generate_random_integer](1,100))
		END
GO

DROP PROCEDURE insert_Ranking

-- EXEC insert_ranking 11
-- SELECT * FROM Ranking

-- EXEC clear_table 'Ranking' 

-- insert a test entry into Player
GO
CREATE OR ALTER PROCEDURE insert_Player @seed INT
	AS
		BEGIN
			INSERT Player(PlayerID,Name,RankingID)
				VALUES
					(@seed,'Djokovic',@seed)
		END
GO

DROP PROCEDURE insert_Player

-- insert a test entry into RGTitle
GO 
CREATE OR ALTER PROCEDURE insert_RGTitle @seed INT
	AS
		BEGIN
			INSERT RGTitle(TitleID,PlayerID,NumberOfTitles)
				VALUES
					(@seed,@seed,[dbo].[generate_random_integer](1,5))
		END
GO
DROP PROCEDURE insert_RGTitle

-- populate a table 
GO
CREATE OR ALTER PROCEDURE populate_table @name varchar(50), @rows int
AS
	BEGIN
		DECLARE @currentRow int, @command varchar(1024)
		SET @currentRow=1
			WHILE @currentRow <= @rows
			BEGIN
				SET @command = 'insert_' + @name + ' ' + CONVERT(varchar(10),@currentRow)
				EXEC (@command) 
				SET @currentRow = @currentRow + 1 
			END
	END
GO

EXEC populate_table 'Ranking', 2

GO
CREATE OR ALTER PROCEDURE create_test @testName varchar(50)
AS
	BEGIN
		IF @testName in (select Name from Tests)
			BEGIN
				PRINT 'TEST' + @testName + 'exists'
				RETURN
			END
		INSERT Tests(Name)
			VALUES(@testName)
	END
GO

CREATE OR ALTER PROCEDURE add_test_table @tableName varchar(50)
AS
	BEGIN
		IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES where TABLE_NAME = @tableName)
		BEGIN
			IF @tableName NOT IN (select Name FROM Tables)
			BEGIN
				INSERT Tables(Name)
				VALUES (@tableName)
			END
			ELSE
				BEGIN
					PRINT 'Table is already added'
				END
		END
		ELSE
			BEGIN
				PRINT 'Table ' + @tableName + ' does not exist'
			END
	END
GO

-- adds an entry into TestTables 
CREATE OR ALTER PROCEDURE add_test_tables
	@tableName varchar(50),
	@testName varchar(50),
	@no_of_rows int,
	@position int
	AS
		BEGIN
			IF @position <=0 
				BEGIN
					PRINT 'Invalid pos'
					RETURN
				END
			IF @no_of_rows <=0
				BEGIN
					PRINT 'Invalid no of rows'
					RETURN
				END

			DECLARE @testId INT, @tableId INT
			SET @testId = (SELECT TestID FROM Tests WHERE Name = @testName)
			IF @testId IS NULL
				BEGIN
					PRINT 'TEST ' + @testName + ' does not exist'
					RETURN
				END
			SET @tableId = (SELECT TableId FROM Tables WHERE Name = @tableName)
			IF @tableId IS NULL
				BEGIN
					PRINT 'TABLE ' + @tableName + ' does not exist'
					RETURN
				END
			BEGIN TRY
				INSERT TestTables(TestID,TableID,NoOfRows,Position)
				VALUES (@testId, @tableId, @no_of_rows, @position)
			END TRY
			BEGIN CATCH
				PRINT error_message()
			END CATCH
		END
GO

-- adds a view into Views Table that stores the views to be tested
CREATE OR ALTER  PROCEDURE add_test_view @viewName varchar(50)
AS
	BEGIN
		IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME=@viewName)
		BEGIN
			IF @viewName NOT IN (SELECT Name from Views)
				BEGIN
					INSERT Views(Name)
					VALUES (@viewName)
				END
			ELSE
				BEGIN
					PRINT 'VIEW ' + @viewName + ' EXISTS'
				END
		END
		ELSE
			BEGIN 
				PRINT 'VIEW ' + @viewName + ' EXISTS'
			END
	END
GO 

-- adds an entry into TestViews

CREATE OR ALTER PROCEDURE add_testViews
	@viewName varchar(50),
	@testName varchar(50)
	AS
		BEGIN
			DECLARE @testId INT, @viewId INT
			set @testId = ( SELECT TestID FROM Tests WHERE Name=@testName)
			IF @testId IS NULL
				BEGIN
					PRINT @testName + 'does not exist'
					RETURN
				END
			SET @viewId = ( SELECT ViewID FROM Views WHERE Name=@viewName)
			IF @viewId IS NULL
				BEGIN
					PRINT @viewName + ' does not exist'
					RETURN
				END
			BEGIN TRY
				INSERT TestViews(TestID,ViewID)
				VALUES (@testId, @viewId) 
			END TRY
			BEGIN CATCH 
				PRINT error_message()
			END CATCH
		END
	GO

CREATE OR ALTER PROCEDURE run_test @testName varchar(50)
AS	
	BEGIN
		DECLARE @testId INT
		SET @testId = (SELECT TestID FROM Tests WHERE Name = @testName)
		IF @testId IS NULL
			BEGIN
				PRINT @testName + ' does not exist'
				RETURN
			END
		-- order all the tables by position for the test
		DECLARE TablesCursor cursor scroll 
		for
		SELECT Tables.TableID, Tables.Name, TestTables.NoOfRows
		FROM TestTables INNER JOIN Tables on TestTables.TableID = Tables.TableID 
		WHERE TestTables.TestID = @testId
		ORDER BY TestTables.Position

		DECLARE ViewsCursor cursor scroll for 
		SELECT V.ViewID, V.Name
			FROM Views V INNER JOIN TestViews TV on V.ViewID = TV.ViewID
			WHERE TV.TestID = @testId
		
		DECLARE
			@table varchar(50),
			@no_of_rows INT,
			@position INT,
			@tableId INT,
			@testStart datetime2,
			@testEnd datetime2,
			@subtestStart datetime2,
			@subtestEnd datetime2,
			@viewId INT, 
			@view varchar(50),
			@testRunId INT,
			@command varchar(512),
			@QUERY varchar(50) 

		SET NOCOUNT ON

		INSERT INTO TestRuns(Description) VALUES
		('Test results for ' + @testName)

		SET @testRunId = CONVERT(INT,(SELECT LAST_VALUE FROM sys.identity_columns WHERE name = 'testRunId')) 
		SET @testStart = SYSDATETIME()

		-- delete data from test tables in order specified by pos
		OPEN TablesCursor
		FETCH FIRST FROM TablesCursor
		INTO @tableId, @table, @no_of_rows
		WHILE @@FETCH_STATUS = 0  -- while fetch is successfull
			BEGIN
				SET @QUERY='clear_table ' + @table
				EXEC (@QUERY)
				FETCH NEXT FROM TablesCursor
					INTO @tableId, @table, @no_of_rows
			END
			CLOSE TablesCursor
		
		-- insert data into test tables in reverse order
		OPEN TablesCursor
		FETCH LAST FROM TablesCursor INTO @tableId, @table, @no_of_rows
		WHILE @@FETCH_STATUS = 0 
			BEGIN
				SET @command = 'populate_table ''' + @table + ''', ' + CONVERT(VARCHAR(10), @no_of_rows)
				SET @subtestStart =SYSDATETIME()
				EXEC (@command)
				SET @subtestEnd = SYSDATETIME()
				PRINT 'FINISHED INSERTING DATA IN ' + @table
				INSERT TestRunTables(TestRunID, TableID, StartAt, EndAt)
				VALUES (@testRunId,@tableId,@subtestStart,@subtestEnd)
				FETCH PRIOR FROM TablesCursor
				INTO @tableId, @table, @no_of_rows
			END
			PRINT 'FINISHED TABLES TEST'

			OPEN ViewsCursor
			FETCH ViewsCursor
			INTO @viewId, @view

			WHILE @@FETCH_STATUS=0
				BEGIN
					-- SET @command = 'select * from ' + @view
					SET @subtestStart = SYSDATETIME()
					-- EXEC (@command)
					SET @subtestEnd = SYSDATETIME()
					INSERT TestRunViews (TestRunID, ViewID, StartAt,EndAt)
					VALUES (@testRunId, @viewId, @subtestStart, @subtestEnd)
					FETCH ViewsCursor
					INTO @viewId, @view
				END 
			SET @testEnd = SYSDATETIME()

			-- add the start/ end time
			UPDATE TestRuns 
			SET StartAt = @testStart, EndAt=@testEnd
			WHERE TestRunID = @testRunId
			
			CLOSE TablesCursor
			CLOSE ViewsCursor
			DEALLOCATE ViewsCursor
			DEALLOCATE TablesCursor

			set nocount off
		END
GO

EXEC add_test_table 'RGTitle'
EXEC add_test_table 'Player'
EXEC add_test_table 'Ranking'

EXEC add_test_view Select1
EXEC add_test_view Select2
EXEC add_test_view Select3

EXEC create_test 't1'
EXEC create_test 't2' 

EXEC add_test_tables 'Ranking', 't1', 500, 3 
EXEC add_test_tables 'Player', 't1', 500, 2 
EXEC add_test_tables 'RGTitle', 't1', 500, 1 

EXEC add_testViews 'Select1', 't1'
EXEC add_testViews 'Select2', 't1'
EXEC add_testViews 'Select3', 't1' 


EXEC run_test 't1'

-- SELECT * FROM Tables
SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM Ranking

GO
CREATE OR ALTER PROCEDURE clearTable @table VARCHAR(50)
AS
    
    DECLARE @querty VARCHAR(50)
    SET @querty = 'DELETE FROM ' + @table
    EXEC (@querty)
    DECLARE @rseed VARCHAR(50)
    IF EXISTS (SELECT * from syscolumns where id = Object_ID(@table) and colstat & 1 = 1)
    BEGIN
    SET @rseed = 'DBCC CHECKIDENT (' + @table + ', RESEED, 0)'
    EXEC (@rseed)
    END
GO

EXEC clear_table 'RGTitle'
EXEC clear_table 'Player'
EXEC clear_table 'Ranking'

EXEC clearTable 'TestTables'
EXEC clearTable 'TestRunTables'
EXEC clearTable 'TestRuns'
EXEC clearTable 'TestViews'
EXEC clearTable 'TestRunViews'

SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews

SELECT * FROM Views