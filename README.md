# Coordenas geográficas
**Archivos .kml** *Google Earth*

### En ocasiones cuando analizamos datos geoespaciales nos interesa calcular la distancia directa entre dos coordenadas geográficas, este repositorio contiene una función en R que permite calcularla, también contiene una query en T-SQL combinada con lenguaje XML para obtener las coordenadas geográficas de los archivos .kml de Google Earth.

## Script en T-SQL para obtener y almacenar las coordenadas geográficas 
```sql
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
  END;
GO

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
  END;
GO

SET @LONG = (
    SELECT LEFT(@COORD,CHARINDEX(',', @COORD)-1)
    ) 
SET @LAT =  (
    SUBSTRING(@COORD, CHARINDEX(',', @COORD) + 1, 50)
    )
SET @LAT =  (
    SELECT LEFT(@LAT,CHARINDEX(',', @LAT)-1)
)
```
##  Creando table Geocoordinates en la base de datos GeocoordinatesDB
```sql
CREATE DATABASE GeocoordinatesDB;
GO

USE GeocoordinatesDB;
GO

CREATE TABLE Geocoordinates (
ID int NOT NULL IDENTITY(1,1),
Location NVARCHAR(95),
Longitude FLOAT,
Latitude  FLOAT
);
GO
```
##  Almacenando las coordenadas dentro de la tabla Geocoordinates
```sql
INSERT INTO Geocoordinates
VALUES(@LOCATION, @LONG, @LAT);
```
###  Mostrando las coordenadas almacenadas
```sql
SELECT *
FROM Geocoordinates
```
