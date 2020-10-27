use RolandGarros
go

-- Inserting Rankings
INSERT INTO Ranking VALUES(1,16);
INSERT INTO Ranking VALUES(2,16);
INSERT INTO Ranking VALUES(3,16);
INSERT INTO Ranking VALUES(4,16);
INSERT INTO Ranking VALUES(5,16);
INSERT INTO Ranking VALUES(6,16);
INSERT INTO Ranking VALUES(7,16);
INSERT INTO Ranking VALUES(8,16);
INSERT INTO Ranking VALUES(9,16);
INSERT INTO Ranking VALUES(10,16);

-- Inserting Players
INSERT INTO Player VALUES(1,'Simona Halep',2);
INSERT INTO Player VALUES(2,'Asleigh Barty',1);
INSERT INTO Player VALUES(3,'Naomi Osaka',3);
INSERT INTO Player VALUES(4,'Sofia Kenin',4);
INSERT INTO Player VALUES(5,'Elina Svitolina',5);
INSERT INTO Player VALUES(6,'Karolina Pliskova',6);
INSERT INTO Player VALUES(7,'Bianca Andreescu',7);
INSERT INTO Player VALUES(8,'Petra Kvitova',8);
INSERT INTO PLAYER VALUES(10,'Serena Williams',9);
INSERT INTO PLAYER VALUES(9,'Kiki Bertens',10);
INSERT INTO Player VALUES(11,'Novak Djokovic',1);
INSERT INTO Player VALUES(22,'Rafael Nadal',2);
INSERT INTO Player VALUES(33,'Dominic Thiem',3);
INSERT INTO Player VALUES(44,'Roger Federer',4);
INSERT INTO Player VALUES(55,'Stefanos Tsitsipas',5);
INSERT INTO Player VALUES(66,'Daniil Medvedev',6);
INSERT INTO Player VALUES(77,'Alexander Zverev',7);
INSERT INTO Player VALUES(88,'Andrey Rublev',8);
INSERT INTO Player VALUES(99,'Matteo Berretini',9);
INSERT INTO Player VALUES(1010,'Diego Schwartzman',10);


-- Inserting Refeeres 1:n
INSERT INTO Referee VALUES(123,'Carlos Ramos');
INSERT INTO Referee VALUES(124,'Alison Hughes');
INSERT INTO Referee VALUES(125,'Eva Asderaki');
INSERT INTO Referee VALUES(126,'Marijana Veljović');
INSERT INTO Referee VALUES(127,'Andrew Jarrett');


-- Inserting Arenas 1:n
INSERT INTO Arena VALUES(700,'Court Philippe Chatrier');
INSERT INTO Arena VALUES(701,'Court Suzanne Lenglen');
INSERT INTO Arena VALUES(702,'Court Simonne Mathieu');
INSERT INTO Arena VALUES(703,'Court 1');

-- Inserting Games
INSERT INTO Game VALUES(51,123,700);
INSERT INTO Game VALUES(52,124,701);
INSERT INTO Game VALUES(53,125,702);
INSERT INTO Game VALUES(54,126,703);
INSERT INTO Game VALUES(55,127,700);
INSERT INTO Game VALUES(56,123,702);
INSERT INTO Game VALUES(57,125,700);
INSERT INTO Game VALUES(58,124,700);
INSERT INTO Game VALUES(59,124,700);

-- Inserting PlayerGame m:n relationship
INSERT INTO PlayerGame VALUES(70,1,2,51);
INSERT INTO PlayerGame VALUES(71,3,8,52);
INSERT INTO PlayerGame VALUES(72,1010,11,53);
INSERT INTO PlayerGame VALUES(73,22,44,54);
INSERT INTO PlayerGame VALUES(74,55,77,55);

-- Inserting Sponsors
INSERT INTO Sponsor VALUES(90,'Uniqlo');
INSERT INTO Sponsor VALUES(900,'Lacoste');
INSERT INTO Sponsor VALUES(909,'Nike');
INSERT INTO Sponsor VALUES(990,'Adidas');
INSERT INTO Sponsor VALUES(999,'Head');
INSERT INTO Sponsor VALUES(9012,'Asics');
INSERT INTO Sponsor VALUES(9011,'Mizuno');
INSERT INTO Sponsor VALUES(9020,'Fila');

-- Inserting SponsorPlayer m:n relationship
INSERT INTO SponsorPlayer VALUES(500,11,900,5000);
INSERT INTO SponsorPlayer VALUES(505,1,909,5000);
INSERT INTO SponsorPlayer VALUES(550,77,990,5000);
INSERT INTO SponsorPlayer VALUES(555,44,90,5000);
INSERT INTO SponsorPlayer VALUES(999,4,999,5000);
INSERT INTO SponsorPlayer VALUES(925,8,909,500);

-- Inserting Ballkids
INSERT INTO Ballkids VALUES(1233,51);
INSERT INTO BallKids VALUES(1234,57);

-- Inserting RG Title
INSERT INTO RGTitle VALUES(1,2);


-- at least one statement should violate referential integrity constraints;
-- INSERT INTO SponsorPlayer VALUES(999,4,999,500);

-- updating data – for at least 3 tables
UPDATE Player 
SET RankingID=10
WHERE Name='Serena Williams'

UPDATE Player 
SET RankingID=9
WHERE PlayerID=9

UPDATE Player 
SET RankingID=1
WHERE Name='Novak Djokovic'

UPDATE Player 
SET RankingID=2
WHERE PlayerID=22


UPDATE Game
SET ArenaID=702
WHERE (RefereeID=124 and ArenaID=700)


UPDATE Ballkids
SET GameID=52
WHERE (GameID=51 or GameID=57)

UPDATE RGTitle
SET PlayerID=1
WHERE PlayerID IS NOT NULL;

-- deleting data for at least 2 tables...

DELETE FROM Game WHERE GameID BETWEEN 56 and 57;

DELETE FROM Sponsor WHERE Name in ('Asics','Mizuno');

DELETE FROM Sponsor WHERE Name LIKE '%F%';

-- a. 2 queries with the union operation; use UNION [ALL] and OR;
-- get the all the players ID

SELECT PlayerID,PlayerID
FROM Player
UNION ALL
SELECT PlayerID1,PlayerID2
FROM PlayerGame

-- get all the players that are first 3 in the rankings OR place 10 
SELECT Name,RankingID
FROM Player
Where RankingID <= 3 or RankingID=10

-- b. 2 queries with the intersection operation; use INTERSECT and IN;
-- get all the players ID that have played in a GAME as the first player
SELECT PlayerID
FROM Player
INTERSECT
SELECT PlayerID1
FROM PlayerGame

-- get all the players' id that are sponsored by Uniqlo or Lacoste
SELECT PlayerID
FROM SponsorPlayer
WHERE SponsorID in (90,900)

-- c. 2 queries with the difference operation; use EXCEPT and NOT IN;
-- get all the players ID that haven't played as FIRST PLAYER in a game
SELECT PlayerID
FROM Player
EXCEPT
SELECT PlayerID1
FROM PlayerGame

-- get all the players' id that are not sponsored by Uniqlo or Lacoste 
SELECT PlayerID
FROM SponsorPlayer
WHERE SponsorID not in (90,900)

-- d. 4 queries with INNER JOIN,
-- LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator); 
-- one query will join at least 3 tables, 
-- while another one will join at least two many-to-many relationships;

-- right join 1 m:n relationship 
-- select all sponsored players
-- if it's NULL it's not sponsored
SELECT SponsorPlayer.PlayerID,SponsorPlayer.SponsorID,PlayerGame.PlayerID1,PlayerGame.PlayerID2
FROM SponsorPlayer
RIGHT JOIN PlayerGame ON (SponsorPlayer.PlayerID=PlayerGame.PlayerID1 or SponsorPlayer.PlayerID=PlayerID2)

-- left join m:n relationship
SELECT SponsorPlayer.PlayerID,SponsorPlayer.SponsorID,PlayerGame.PlayerID1,PlayerGame.PlayerID2
FROM SponsorPlayer
LEFT JOIN PlayerGame ON (SponsorPlayer.PlayerID=PlayerGame.PlayerID1 or SponsorPlayer.PlayerID=PlayerID2)

-- inner join 3 tables
SELECT Player.Name, Sponsor.Name, SponsorPlayer.SponsorshipSum
FROM((SponsorPlayer INNER JOIN Player on SponsorPlayer.PlayerID=Player.PlayerID) INNER JOIN Sponsor on SponsorPlayer.SponsorID=Sponsor.SponsorID);

-- full join
SELECT TOP 2 SponsorPlayer.PlayerID,SponsorPlayer.SponsorID,PlayerGame.PlayerID1,PlayerGame.PlayerID2
FROM SponsorPlayer
FULL JOIN PlayerGame ON (SponsorPlayer.PlayerID=PlayerGame.PlayerID1 or SponsorPlayer.PlayerID=PlayerID2)

-- e. 2 queries with the IN operator and a subquery in the WHERE clause;
-- in at least one case, the subquery should include a subquery in its own WHERE clause;


-- find the name of the players that are Sponsored by Nike
SELECT Player1.Name
FROM Player Player1
WHERE Player1.PlayerID IN
(SELECT Sponsored.PlayerID
FROM SponsorPlayer Sponsored
WHERE Sponsored.SponsorID=909) 

-- find the name of the players that played on game with ID 70 and is also sponsored by Nike
SELECT P.Name
FROM Player P
WHERE P.PlayerID IN
(
	SELECT G.PlayerID1
	FROM PlayerGame G
	WHERE G.GameID=70 OR G.PlayerID1 IN 
	(
		SELECT Sponsored.PlayerID
		FROM SponsorPlayer Sponsored
		WHERE Sponsored.SponsorID=909
	)
)

-- f. 2 queries with the EXISTS operator and a subquery in the WHERE clause;
-- find the name of the Sponsor of the player with id 44

SELECT S.Name
FROM Sponsor S
WHERE EXISTS
(
SELECT * FROM SponsorPlayer SP
WHERE SP.PlayerID=44 AND SP.SponsorID=S.SponsorID
)

-- get the ranking and the name of the players who were on game 70

SELECT P.Name, P.RankingID, P2.Name, P2.RankingID
FROM Player P, Player P2
WHERE EXISTS
(
	SELECT * FROM PlayerGame PG
	WHERE P.PlayerID=PG.PlayerID1 AND P2.PlayerID=PG.PlayerID2 AND(PG.GameID=51)
)

-- g. 2 queries with a subquery in the FROM clause

-- * about players that are Sponsored by Nike
SELECT P.*
FROM Player P INNER JOIN
(
SELECT * 
FROM SponsorPlayer SP
WHERE SP.SponsorID=909
) 
as X ON P.PlayerID = X.PlayerID

-- get everything about the game played with the id 70 in PlayerGame
SELECT G.*
FROM Game G INNER JOIN
(
SELECT * 
FROM PlayerGame PG
WHERE PG.Games=70
)
as X ON G.GameID=X.GameID

-- h. 4 queries with the GROUP BY clause, 
-- 3 of which also contain the HAVING clause;
-- 2 of the latter will also have a subquery in the HAVING clause; 
-- use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;

-- get the min Referee ID for each arena
SELECT G.ArenaID, MIN(G.RefereeID) MaxRank
FROM Game G 
GROUP BY G.ArenaID

-- get all Sponsors which have the biggest nr of Players
SELECT SP.SponsorID, COUNT(*) nrOfPlayers
FROM SponsorPlayer SP
GROUP BY SP.SponsorID
HAVING COUNT(*)=(SELECT MAX(nrOfPlayers) FROM
					(SELECT COUNT(*) nrOfPlayers
					FROM SponsorPlayer SP
					GROUP BY SP.SponsorID) sponsor)

-- get all the arenas in which games are played at least 1 time 
SELECT G.ArenaID, COUNT(G.ArenaID) nrOfGamesOnThatArena
FROM Game G
GROUP BY G.ArenaID
HAVING COUNT(G.ArenaID)>=1
ORDER BY nrOfGamesOnThatArena DESC

-- get all the Player Rankings which have a ranking more than average
SELECT P.RankingID
FROM Player P
GROUP BY P.RankingID
HAVING P.RankingID > 
(
SELECT AVG(R.RankingID) AverageRank
FROM Ranking R
)
ORDER BY P.RankingID DESC

-- 4 queries using ANY and ALL to introduce
-- a subquery in the WHERE clause ( 2 queries per operator ) 
-- rewrite 2 of them with aggreggation operators
-- the other 2 with IN/ [NOT] IN

-- gets all the players which have the ranking id smaller than any of the 
-- players with the name Roger Federer
SELECT DISTINCT P.Name
FROM Player P
WHERE P.RankingID>ANY
(
SELECT P2.RankingID
FROM Player P2
WHERE P2.Name='Roger Federer' 
)
ORDER BY P.Name DESC

-- find the ID of all the games who have their arena different from 700
SELECT DISTINCT G.GameID,G.ArenaID
FROM Game G
WHERE G.ArenaID <> ALL
(
SELECT G2.ArenaID
FROM Game G2
WHERE G2.ArenaID=700
)

-- rewriting the first one with IN 
SELECT DISTINCT TOP 2 P.Name, P.RankingID
FROM Player P
WHERE P.RankingID IN
(
SELECT P2.RankingID
FROM Player P2
WHERE P2.Name='Roger Federer' 
)
ORDER BY P.Name DESC

-- rewriting the second one with NOT IN.. 
SELECT DISTINCT G.GameID,G.ArenaID
FROM GAME G
WHERE G.ArenaID NOT IN
(
SELECT G2.ArenaID
FROM Game G2
WHERE G2.ArenaID=700
)

SELECT P.Name
FROM Player P
WHERE P.RankingID<ANY
(
SELECT P2.RankingID
FROM Player P2
WHERE P2.Name='Naomi Osaka'
)

-- rewriting it with aggregation... MAX
SELECT P.Name
FROM Player P
WHERE P.RankingID<(
SELECT MAX(P2.RankingID) FROM Player P2 
WHERE P2.Name='Naomi Osaka')


SELECT P.Name
FROM Player P
WHERE P.RankingID>ANY
(
SELECT P2.RankingID
FROM Player P2
WHERE P2.Name='Petra Kvitova'
)

-- rewriting it with aggregation... MIN
SELECT P.Name
FROM Player P
WHERE P.RankingID>(
SELECT MIN(P2.RankingID) FROM Player P2 
WHERE P2.Name='Petra Kvitova')
