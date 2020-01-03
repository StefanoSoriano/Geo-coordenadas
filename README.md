# Coordenas geográficas
**Archivos .kml** *Google Earth*

### En ocasiones cuando analizamos datos geoespaciales nos interesa calcular la distancia directa entre dos coordenadas geográficas, este repositorio contiene una función en R que permite calcularla, también contiene una query en T-SQL combinada con lenguaje XML para obtener las coordenadas geográficas de los archivos .kml de Google Earth.

###  La siguiente función la tomé del libro [Data Science with Microsoft SQL Server 2016](https://blogs.msdn.microsoft.com/microsoft_press/2016/10/19/free-ebook-data-science-with-microsoft-sql-server-2016/) página número 30.

### Debido a que la función escrita en dicho libro está en lenguaje T-SQL la transformé a lenguaje R, además, transformé la unidad de medida de longitud del radio de la tierra de millas terrestres a kilómetros y redondeé la distancia a dos dígitos decimales.
##### _Radio de la tierra medido en millas terrestres_ = 3958.75 mi
##### _Radio de la tierra medido en kilómetros_ = 6,371.00 km

## Script en R para calcular la distancia directa entre dos coordenadas geográficas
```r
setwd("C:/Users/../..")
geoespacial <- read.csv("coordinates.csv", header = T, stringsAsFactors = F)
geoespacialLAG <- geoespacial[-1,]

long1 <- geoespacial$Longitude
lat1 <- geoespacial$Latitude
long2 <- geoespacialLAG$Longitude
lat2 <- geoespacialLAG$Latitude

CalculateDist <- function(long1, lat1, long2, lat2) {
    #  Convirtiendo coordenadas a radianes
    long1 <- long1 / 57.2958
    lat1 <- lat1 / 57.2958
    long2 <- long2 / 57.2958
    lat2 <- lat2 / 57.2958
    #  Calculando la distancia 
    distance <- (sin(lat1) * sin(lat2)) + (cos(lat1) * cos(lat2) * cos(long2 - long1))
    if (distance != 0) {
        radius <- (3958.75 * 1.609344) #  Convirtiendo radio de la tierra de millas terrestres a kilómetros 
        distance = radius * atan(sqrt(1 - (distance^2)) / distance)
        distance <- round(distance, digits = 2)
    }
    return(distance)  
}
```
###  Obteniendo la distancia en kilómetros
```r
distancia_directa <- CalculateDist(long1, lat1, long2, lat2)
index_0 <- which.min(distancia_directa)
info_distancia <- paste("La distancia directa entre", 
                         geoespacial$Location,"y", 
                         geoespacialLAG$Location,"es de",
                         distancia_directa,"km", 
                         sep = " ")
info_distancia <- info_distancia[-c(index_0)]
info_distancia
```

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
