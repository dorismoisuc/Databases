Create database RolandGarros
go
use RolandGarros
go


CREATE TABLE Ranking
(RankingID INT PRIMARY KEY IDENTITY,
NumberOfPlayers INT NOT NULL)



CREATE TABLE Arena
(
ArenaID INT PRIMARY KEY IDENTITY,
Name varchar(50) NOT NULL)


CREATE TABLE Player
(PlayerID INT PRIMARY KEY IDENTITY, 
Name varchar(50) NOT NULL,
RankingID INT FOREIGN KEY REFERENCES Ranking(RankingID))

CREATE TABLE Referee
(
RefereeID INT PRIMARY KEY IDENTITY,
Name varchar(50) NOT NULL)

CREATE TABLE Game
(
GameID INT PRIMARY KEY IDENTITY,
RefereeID INT FOREIGN KEY REFERENCES Referee(RefereeID),
ArenaID INT FOREIGN KEY REFERENCES Arena(ArenaID))


CREATE TABLE Ballkids
(
BallKidID INT PRIMARY KEY IDENTITY,
GameID INT FOREIGN KEY REFERENCES Game(GameID))


CREATE TABLE Sponsor
(
SponsorID INT PRIMARY KEY IDENTITY,
Name varchar(50) NOT NULL)


CREATE TABLE SponsorPlayer
(
SponsorPlayer INT PRIMARY KEY IDENTITY,
PlayerID INT FOREIGN KEY REFERENCES Player(PlayerID),
SponsorID INT FOREIGN KEY REFERENCES Sponsor(SponsorID),
SponsorshipSum INT NOT NULL)


CREATE TABLE PlayerGame
(
Games INT PRIMARY KEY IDENTITY,
PlayerID1 INT FOREIGN KEY REFERENCES Player(PlayerID),
PlayerID2 INT FOREIGN KEY REFERENCES Player(PlayerID),
GameID INT FOREIGN KEY REFERENCES Game(GameID))


CREATE TABLE RGTitle
(
TitleID INT PRIMARY KEY,
PlayerID INT FOREIGN KEY REFERENCES Player(PlayerID))
