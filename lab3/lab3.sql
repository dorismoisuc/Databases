use RolandGarros
go


-- I will name the procedures after the versions, makeVERSION1, remakeVERSION1, etc.. 


-- a. modify the type of a column
-- VERSION1 

-- make VERSION1... 
-- modifying a column
CREATE PROCEDURE makeV1 AS
BEGIN
	ALTER TABLE Referee
	ALTER COLUMN Name nvarchar
	PRINT('Modified a column')
END
GO
-- EXEC makeV1

sp_help 'Referee'
DROP PROCEDURE makeV1
-- remake VERSION1

CREATE PROCEDURE remakeV1 AS
BEGIN
	ALTER TABLE Referee
	ALTER COLUMN Name varchar
	PRINT('Remodified a column')
END
GO

-- EXEC remakeV1

-- b. add / remove a column;
-- VERSION2

--removing a column
CREATE PROCEDURE makeV2 AS
BEGIN
	ALTER TABLE Referee
	DROP COLUMN Name
	PRINT('Removed a column')
END
GO
-- EXEC makeV2

-- REMAKE VERSION2
-- adding a column
CREATE PROCEDURE remakeV2 AS
BEGIN
	ALTER TABLE Referee
	ADD Name varchar(50)  
	PRINT('Added a column')
END
GO
-- EXEC remakeV2

-- c. add / remove a DEFAULT constraint;
-- adding a default constraint

CREATE PROCEDURE makeV3 AS
BEGIN
	ALTER TABLE Arena
	ADD CONSTRAINT default_name DEFAULT 'Arena' FOR Name
	PRINT('Make version 3, added a default name for every Arena')
END
GO
-- EXEC makeV3

-- removing a default constraint

CREATE PROCEDURE remakeV3 AS
BEGIN
	ALTER TABLE Arena
	DROP CONSTRAINT default_name 
	PRINT('Remake version3, removed the default name for every Arena')
END
GO
-- EXEC remakeV3

-- d. add / remove a primary key;

-- removing a PRIMARY KEY

sp_help 'RGTitle'

-- PrimaryKey: PK__RGTitle__757589E6160BB8BF
-- ForeignKey: FK__RGTitle__PlayerI__3F466844

-- remove primary key
CREATE PROCEDURE makeV4 AS
BEGIN
	ALTER TABLE RGTitle
	DROP CONSTRAINT TitleID
	PRINT('Removed primary key from RGTitle')
END
GO
EXEC makeV4

-- add primary key
CREATE PROCEDURE remakeV4 AS
BEGIN
	ALTER TABLE RGTitle
	ADD CONSTRAINT TitleID PRIMARY KEY(TitleID)
	PRINT('Added primary key for RGTitle')
END
GO
EXEC remakeV4


-- e. add / remove a candidate key;
-- adding a candidate key 
-- tuple between player_name and player_rank
CREATE PROCEDURE makeV5 AS
BEGIN
	ALTER TABLE Player
	ADD CONSTRAINT unique_player_name_rank UNIQUE (Name,RankingID)
	PRINT('Added a candidate key playername_playerank, because it cannot be duplicated')
END
GO
 EXEC makeV5

CREATE PROCEDURE remakeV5 AS
BEGIN
	ALTER TABLE Player
	DROP CONSTRAINT unique_player_name_rank
	PRINT('Removed the candidate key')
END
GO
EXEC remakeV5

-- f. add / remove a foreign key;

-- remove a foreign key

CREATE PROCEDURE makeV6 AS
BEGIN
	ALTER TABLE RGTitle
	DROP CONSTRAINT PlayerID
	PRINT('Removed the foreign key')
END
GO
-- EXEC makeV6
sp_help 'RGTitle'
-- add a foreign key 

CREATE PROCEDURE remakeV6 AS
BEGIN
	ALTER TABLE RGTitle
	ADD CONSTRAINT PlayerID FOREIGN KEY(PlayerID) REFERENCES Player(PlayerID)
	PRINT('Added a foreign key')
END
GO
-- EXEC remakeV6

-- g. create / drop a table

-- dropping a table
CREATE PROCEDURE makeV7 AS
BEGIN 
	DROP TABLE IF EXISTS Ballkids
	print('Dropped the table Ballkids')
END
GO
-- EXEC makeV7

-- creating a table
CREATE PROCEDURE remakeV7 AS
BEGIN
	CREATE TABLE Ballkids
	(
		BallKidID INT PRIMARY KEY IDENTITY,
		GameID INT FOREIGN KEY REFERENCES Game(GameID)
	);
	print('Created a table')
END
GO

-- EXEC remakeV7

-- Create a new table that holds the current version 
-- of the database schema. 
-- Simplifying assumption: 
-- -> the version is an integer number.
-- Write a stored procedure that receives as a parameter a 
-- version number and brings the database to that version.

-- creating a new table that holds the current version
-- of the database schema

DROP TABLE IF EXISTS DatabaseSchema

CREATE TABLE DatabaseSchema
(
	dbID INT IDENTITY (1,1) PRIMARY KEY,
	cVersion INT
);


-- SELECT * FROM DatabaseSchema

-- INSERT INTO DatabaseSchema VALUES(0);
-- INSERT INTO DatabaseSchema VALUES(7);

GO
CREATE PROCEDURE selectVersion
	@selectedVersion INT AS
	BEGIN
		DECLARE @currentVersion INT
		SET @currentVersion = (SELECT cVersion
							   FROM DatabaseSchema)
		DECLARE @procedure VARCHAR(50)
		IF @selectedVersion < 0 OR @selectedVersion > 7 
			BEGIN
				PRINT('The version chosen must be between 0 and 7')
			END
		ELSE
			BEGIN
				IF @selectedVersion > @currentVersion
				BEGIN
					WHILE @selectedVersion > @currentVersion
					BEGIN
						SET @currentVersion = @currentVersion+1
						SET @procedure = 'MAKEV' + CAST(@currentVersion as varchar(5))
						EXEC @procedure
					END
				END
				ELSE
				BEGIN
					WHILE @selectedVersion<@currentVersion
					BEGIN
						IF @currentVersion!=0
						BEGIN
							SET @procedure='REMAKEV' + CAST(@currentVersion as varchar(5))
							EXEC @procedure
						END
						set @currentVersion=@currentVersion-1
					END
				END
				TRUNCATE TABLE DatabaseSchema
				INSERT INTO DatabaseSchema VALUES (@selectedVersion)
			END
	END
	


EXEC selectVersion 4

SELECT * FROM DatabaseSchema


DROP PROCEDURE selectVersion

