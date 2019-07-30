/* Query en lenguaje T-SQL que obtiene las coordenadas geográficas de un archivo .kml de Google Earth */

DECLARE @XML XML
SELECT @XML = XML_GEO
FROM OPENROWSET(BULK 'C:\Users\..\..\San Francisco California.kml' , SINGLE_BLOB) AS GEO(XML_GEO)
DECLARE @XML_EST XML = (SELECT @XML
FOR XML RAW('Earth'))
DECLARE @idoc int
EXEC sp_xml_preparedocument @idoc OUTPUT, @XML_EST

DECLARE @LOCNAME VARCHAR(50), @LOCADD VARCHAR(50), @COORD VARCHAR(50)

SET @LOCNAME = (
SELECT MAX(id)
FROM OPENXML (@idoc, '/Earth', 1)
WHERE localname = 'name')

SET @LOCADD = (
SELECT id 
FROM OPENXML (@idoc, '/Earth', 1)
WHERE localname = 'address')

SET @COORD = (
SELECT MIN(id)
FROM OPENXML (@idoc, '/Earth', 1)
WHERE localname = 'coordinates')


SET @COORD = (SELECT [text] as Longitude 
             FROM OPENXML (@idoc, '/Earth', 1)  
			 WHERE parentid = @COORD)

/*SELECT *
FROM OPENXML (@idoc, '/Earth', 1) */


SET @LOCNAME = (SELECT [text] as Location 
            FROM OPENXML (@idoc, '/Earth', 1)  
			WHERE parentid = @LOCNAME)

IF @LOCNAME = 'placepageUri'
  BEGIN
     SET @LOCNAME = (
     SELECT MIN(id)
     FROM OPENXML (@idoc, '/Earth', 1)
     WHERE localname = 'name')
      SET @LOCNAME = (SELECT [text] as Location 
           FROM OPENXML (@idoc, '/Earth', 1)  
			WHERE parentid = @LOCNAME)
  END
ELSE
  BEGIN
     SET @LOCNAME = @LOCNAME
  END

SET @LOCADD = (SELECT [text] as Location 
            FROM OPENXML (@idoc, '/Earth', 1)  
			WHERE parentid = @LOCADD)

DECLARE @LOCATION VARCHAR(100), @LONG FLOAT, @LAT VARCHAR(50)

IF @LOCADD IS NOT NULL
  BEGIN
   SET @LOCATION = @LOCNAME + ', ' + @LOCADD
  END
ELSE 
  BEGIN
   SET @LOCATION = @LOCNAME
  END

SET @LONG = (
    SELECT LEFT(@COORD,CHARINDEX(',', @COORD)-1)
    ) 
SET @LAT =  (
    SUBSTRING(@COORD, CHARINDEX(',', @COORD) + 1, 50)
    )
SET @LAT =  (
    SELECT LEFT(@LAT,CHARINDEX(',', @LAT)-1)
)

/*SELECT @LOCATION AS Location, 
       @LONG AS Longitude, 
	   @LAT as Latitude
*/


/*CREATE DATABASE GeocoordinatesDB;
GO*/

USE GeocoordinatesDB;

/*DROP TABLE Geocoordinates

CREATE TABLE Geocoordinates (
ID int NOT NULL IDENTITY(1,1),
Location NVARCHAR(95),
Longitude FLOAT,
Latitude  FLOAT
)*/


/*TRUNCATE TABLE Geocoordinates;*/


INSERT INTO Geocoordinates
VALUES(@LOCATION, @LONG, @LAT);

SELECT *
FROM Geocoordinates
GO

