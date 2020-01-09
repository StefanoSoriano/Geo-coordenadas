# Coordenas geográficas
**Archivos .kml** *Google Earth*

### En ocasiones cuando analizamos datos georrelacionados nos interesa calcular la distancia directa entre dos coordenadas geográficas, este repositorio contiene una función en R que permite calcularla, también contiene una query en T-SQL combinada con lenguaje XML para obtener las coordenadas geográficas de los archivos .kml de Google Earth.

###  La siguiente función la tomé del libro [Data Science with Microsoft SQL Server 2016](https://blogs.msdn.microsoft.com/microsoft_press/2016/10/19/free-ebook-data-science-with-microsoft-sql-server-2016/) página número 30.

### Debido a que la función escrita en dicho libro está en lenguaje T-SQL la transformé a lenguaje R, además, transformé la unidad de medida de longitud del radio de la tierra de millas terrestres a kilómetros y redondeé la distancia a dos dígitos decimales.
##### _Radio de la tierra medido en millas terrestres_ = 3958.75 mi
##### _Radio de la tierra medido en kilómetros_ = 6,371.00 km

## Script en R para calcular la distancia directa entre dos coordenadas geográficas
```r
setwd("C:/../../..")
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
###  Archivo .kml obtenido de Google Earth 
**Ubicación:** San Francisco California
```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Placemark id="1.2.1">
	<name>San Francisco</name>
	<address>California, EE. UU.</address>
	<snippet>California, EE. UU.</snippet>
	<description><![CDATA[<!DOCTYPE html><html><head></head><body><script type="text/javascript">window.location.href="https://www.google.com/earth/rpc/entity?lat=37.75769999999999&lng=-122.43759999999999&fid=0x80859a6d00690021:0x4a501367f076adff&hl=es-419&gl=mx&client=earth-client&cv=7.3.2.5776&useragent=GoogleEarth/7.3.2.5776(Windows;Microsoft Windows (6.2.9200.0);es-419;kml:2.2;client:Pro;type:default)";</script></body></html>]]></description>
	<styleUrl>#geocode</styleUrl>
	<ExtendedData>
		<Data name="placepageUri">
			<value>https://www.google.com/earth/rpc/entity?lat=37.75769999999999&amp;lng=-122.43759999999999&amp;fid=0x80859a6d00690021:0x4a501367f076adff&amp;hl=es-419&amp;gl=mx&amp;client=earth-client&amp;cv=7.3.2.5776&amp;useragent=GoogleEarth/7.3.2.5776(Windows;Microsoft Windows (6.2.9200.0);es-419;kml:2.2;client:Pro;type:default)</value>
		</Data>
	</ExtendedData>
	<MultiGeometry>
		<Point>
			<coordinates>-122.4194155,37.7749295,0</coordinates>
		</Point>
		<LinearRing>
			<coordinates>
				-122.5301100709413,37.69190857179407,0 -122.5301100709413,37.85795042820593,0 -122.3087209290588,37.85795042820593,0 -122.3087209290588,37.69190857179407,0 -122.5301100709413,37.69190857179407,0 
			</coordinates>
		</LinearRing>
	</MultiGeometry>
</Placemark>
</kml>
```

### Script en T-SQL para obtener y acumular las coordenadas geográficas de una ubicación almacenada en un archivo .kml
```sql
DECLARE @XML XML
SELECT @XML = XML_GEO
FROM OPENROWSET(BULK 'C:\..\..\..\San Francisco California.kml' , SINGLE_BLOB) AS GEO(XML_GEO)
DECLARE @XML_EST XML = (SELECT @XML FOR XML RAW('Earth'))
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
##  Creando la tabla Geocoordinates en la base de datos GeocoordinatesDB
```sql
CREATE DATABASE GeocoordinatesDB;
GO

USE GeocoordinatesDB;
GO

CREATE TABLE Geocoordinates (
ID INT    IDENTITY (1,1) NOT NULL,
Location  NVARCHAR (95)  NOT NULL,
Longitude FLOAT          NOT NULL,
Latitude  FLOAT          NOT NULL
);
GO
```
##  Acumulando las coordenadas dentro de la tabla Geocoordinates
```sql
INSERT INTO Geocoordinates
VALUES(@LOCATION, @LONG, @LAT);
GO
```
##  Mostrando las coordenadas acumuladas
```sql
SELECT *
FROM Geocoordinates;
GO
```

