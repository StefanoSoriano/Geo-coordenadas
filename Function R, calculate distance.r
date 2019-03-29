#  página número 30. Debido a que la función escrita en dicho libro
#  está en lenguaje T-SQL la tranformé a lenguaje R, 
#  además tranformé la unidad de medida de longitud del radio de la tierra de millas terrestres a kilómetros
#  y redondeé la distancia a dos dígitos decimales.
#  RADIO DE LA TIERRA MEDIDO EN MILLAS TERRESTRES = 3958.75 mi
#  RADIO DE LA TIERRA MEDIDO EN KILÓMETROS = 6,371.00 km

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

#  Obteniendo información 

distancia_directa <- CalculateDist(long1, lat1, long2, lat2)
index_0 <- which.min(distancia_directa)
info_distancia <- paste("La distancia directa entre", 
                         geoespacial$Location,"y", 
                         geoespacialLAG$Location,"es de",
                         distancia_directa,"kilómetros.", 
                         sep = " ")
info_distancia <- info_distancia[-c(index_0)]
info_distancia


#  Entonces, la función tiene cuatro argumentos formales los cuales "leerán" las coordenas geográficas correspondientes.
#  Así, por ejemplo, al analizar un data frame que contenga información geoespacial y querer calcular la distancia entre
#  dos coordenas;
