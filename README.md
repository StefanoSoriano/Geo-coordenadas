# Geographic coordinates
En ocasiones cuando analizamos datos geoespaciales nos interesa calcular la distancia directa entre dos coordenadas geográficas,
este repositorio contiene una función en lenguaje R que permite calcularla, también contiene un query en lenguaje T-SQL 
combinado con lenguaje XML para obtener las coordenadas geográficas de los archivos .kml de Google Earth.

#### Ejemplo: Teniendo el siguiente data frame

---
ID: 	1	2	3	4	5	6	7	8	9	10
Location:	Acrópolis de Atenas, Atenas 105 58, Grecia	Alhambra, Calle Real de la Alhambra, s/n, 18009 Granada	Chichén Itzá, Yucatán, México	Coliseo de Roma, Piazza del Colosseo, 1, 00184 Roma RM, Italia	Cristo Redentor, Parque Nacional da Tijuca - Alto da Boa Vista, Rio de Janeiro	Gran Pirámide de Guiza, Al Haram, Nazlet El-Semman, Al Haram, Giza Governo	Machu Picchu, Perú	Muralla China, Huairou, China	Petra, Jordania	Taj Mahal, Dharmapuri, Forest Colony, Tajganj, Agra
Longitude:	23.7257492	-3.5881413	-88.5683091	12.4922309	-43.2104872	31.1342019	-72.5449629	116.5703749	35.4443622	78.0421552
Latitude:	37.9715323	37.1760783	20.6791438	41.8902102	-22.951916	29.9792345	-13.1631412	40.4319077	30.3284544	27.1750151

---
