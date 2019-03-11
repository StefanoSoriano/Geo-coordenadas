#  La siguiente función la tomé del libro Data Science with Microsoft SQL Server 2016, 
#  página número 30. Debido a que la función escrita en dicho libro
#  está en lenguaje T-SQL la tranformé a lenguaje R, 
#  además tranformé la unidad de medida de longitud del radio de la tierra de millas terrestres a kilómetros.
#  RADIO DE LA TIERRA MEDIDO EN MILLAS TERRESTRES = 3958.75 mi
#  RADIO DE LA TIERRA MEDIDO EN KILÓMETROS = 6,371.00 km


CalculateDist <- function(long1, lat1, long2, lat2) {
    #  Convirtiendo coordenadas a radianes
    long1 <- long1 / 57.2958
    lat1 <- lat1 / 57.2958
    long2 <- long2 / 57.2958
    lat2 <- lat2 / 57.2958
    #  Calculando la distancia 
    distance <- (sin(lat1) * sin(lat2)) + (cos(lat1) * cos(lat2) * cos(long2 - long1))
    #  Convirtiendo a Kilómetros
    if (distance != 0) {
        distance = 6371 * atan(sqrt(1 - (distance^2)) / distance)
    }
    return(distance)  
}

#  Entonces, la función tiene cuatro argumentos formales los cuales "leerán" las coordenas geográficas correspondientes.
#  Así por ejemplo, al analizar un data.frame que contenga información geo-espacial y querer calcular la distancia entre
#  dos coordenas;