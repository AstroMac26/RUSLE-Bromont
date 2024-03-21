# ******************************************************************************
# 1. Environnement de travail --------------------------------------------------
# ******************************************************************************
## Nettoyage l'environnement de travail
rm(list=ls())

# Load required libraries
library(sf)
library(terra)
# ******************************************************************************
# 2. Importer les données ------------------------------------------------------
# ******************************************************************************
# Define the file path to your GeoTIFF image
Bromont <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A2noP.tif")
Gale <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A2noPGale.tif")

plot(Bromont)

#Classification selon 5 niveaux - Bromont
Bromont[Bromont >= 2] <- 5
Bromont[Bromont >= 1 & Bromont < 2] <- 4
Bromont[Bromont >= 0.5 & Bromont < 1] <- 3
Bromont[Bromont >= 0 & Bromont < 0.5] <- 2
Bromont[Bromont < 0] <- 1


#Classification selon 5 niveaux - Gale
Gale[Gale >= 2] <- 5
Gale[Gale >= 1 & Gale < 2] <- 4
Gale[Gale >= 0.5 & Gale < 1] <- 3
Gale[Gale >= 0 & Gale < 0.5] <- 2
Gale[Gale < 0] <- 1

#Display results
plot(Gale)
plot(Bromont)

#Enregistrer les résultats
writeRaster(Bromont, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/Bromont_classification_levels.tif", 
            overwrite=TRUE)

writeRaster(Gale, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/Gale_classification_levels.tif", 
            overwrite=TRUE)

