/*  Query en lenguaje T-SQL que obtiene las coordenadas geográficas de un archino kml
    obtenido de Google Earth */


DECLARE @XML XML
SELECT @XML = XML_GEO
FROM OPENROWSET(BULK 'C:\Users\..\Tibet.kml', SINGLE_BLOB) AS GEO(XML_GEO)
DECLARE @XML_EST XML = (SELECT @XML
FOR XML RAW('Earth'))
SELECT @XML_EST
DECLARE @idoc int
EXEC sp_xml_preparedocument @idoc OUTPUT, @XML_EST;
SELECT [text] AS [Coordenadas / Long-Lat] 
FROM OPENXML (@idoc, '/Earth', 1) 
WHERE parentid = 52
GO

-- Así que, teniendo el siguiente documento XML obtenido de un documento KML de Google Earth
-- que corresponde a Xaitongmoin, China
/*
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>Tibet.kml</name>
	<StyleMap id="m_ylw-pushpin">
		<Pair>
			<key>normal</key>
			<styleUrl>#s_ylw-pushpin</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#s_ylw-pushpin_hl</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="s_ylw-pushpin">
		<IconStyle>
			<scale>1.1</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
	</Style>
	<Style id="s_ylw-pushpin_hl">
		<IconStyle>
			<scale>1.3</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/pushpin/ylw-pushpin.png</href>
			</Icon>
			<hotSpot x="20" y="2" xunits="pixels" yunits="pixels"/>
		</IconStyle>
	</Style>
	<Placemark>
		<name>Tibet</name>
		<LookAt>
			<longitude>88.78786767973863</longitude>
			<latitude>30.15338133989719</latitude>
			<altitude>0</altitude>
			<heading>-8.175654126434494e-007</heading>
			<tilt>47.93730934331231</tilt>
			<range>920.1464115251295</range>
			<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
		</LookAt>
		<styleUrl>#m_ylw-pushpin</styleUrl>
		<Point>
			<gx:drawOrder>1</gx:drawOrder>
			<coordinates>88.78786767973863,30.15338133989719,0</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
*/
 
