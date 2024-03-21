# ******************************************************************************
# 1. Environnement de travail --------------------------------------------------
# ******************************************************************************
#Si whitebox casse utiliser ces commandes pour le réinstaller ou utiliser "packages en bas à gauche
remove.packages("whitebox")
devtools::install_github("giswqs/whiteboxR")
whitebox::wbt_init
## Nettoyage l'environnement de travail
rm(list=ls())
# Load required libraries
library(sp)
library(sf)
library(tmap)
library(terra)
library(whitebox)

# ******************************************************************************
# 2. Importer les données ------------------------------------------------------
# ******************************************************************************
# Define the file path to your GeoTIFF image
DEM_path <- "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/Watersheds/MNT_31H07SE.tif"
# Read the GeoTIFF file
raster_data <- rast(DEM_path)
# Print information about the raster
print(raster_data)

# Lire le shapefile avec tmap
shape_path <-  st_read("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/Watersheds/Watershed.shp")

# Cartographier le shapefile avec tmap
tmap_mode("plot")

tm_shape(shape_path) +
  tm_borders()  # Afficher les bordures du shapefile

# ******************************************************************************
# 3. Couper le raster avec zone d'étude ----------------------------------------
# ******************************************************************************

#Reprojeter la couche raster dans la même projection que le BV
crs <- crs(shape_path)
# Reprojeter les différents rasters en fonction du crs du Bassin Versant
raster_data <- project(raster_data, crs)
#Calucler la bounding box du shapefile
bbox <- st_bbox(shape_path)

# Crop the raster data with bounding box
raster_cropped <- crop(raster_data, bbox)

tm_shape(raster_cropped)+
  tm_raster(style = "cont",palette = "-Greys", legend.show = FALSE)

# Specify the file path and name for the output GeoTIFF
output_file <- "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/Watersheds/Galeraster_cropped.tif"
# Export the analyzed raster to a GeoTIFF file
writeRaster(raster_cropped, filename=output_file, overwrite=TRUE)


# ******************************************************************************
# 4. Calcul du facteur LS ------------------------------------------------------
# ******************************************************************************
## 4.1 Calcul des données hydrologiques-----------------------------------------

#Définir le répertoire de travail pour les analayses
setwd("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/Watersheds")

#Corriger les depression en remplissant le DEM avec la méthode Wang and Liu
input <- "Galeraster_cropped.tif"
output <- "raster_fill_wang_and_liu.tif"
raster_depression <- wbt_fill_depressions_wang_and_liu(input, output)


#Calculer longueur chemin d'écoulement
input <- "raster_fill_wang_and_liu.tif"
output <- "raster_max_upslope_flowpath_length.tif"
raster_flowpath_length <- wbt_max_upslope_flowpath_length(input, output)

#Calculer la pente
input <- "raster_fill_wang_and_liu.tif"
output <- "raster_slopes.tif"
raster_slope <- wbt_slope(input, output, units = "degrees")

#faire la classification du m
pente <- rast("raster_slopes.tif")
plot(pente)
pente[pente < 1] <- 0.2
pente[pente >= 1 & pente < 3.5] <- 0.3
pente[pente >= 3.5 & pente < 5] <- 0.4
pente[pente >= 5] <- 0.5

plot(pente)
writeRaster(pente, "raster_classified.tif", overwrite=TRUE)

## 4.2 Calcul du facteur L------------------------------------------------------
lambda <- rast("raster_max_upslope_flowpath_length.tif")
psi <- 22.13
m <- rast("raster_classified.tif")
L <- (lambda/psi)^m
writeRaster(L, "raster_L.tif", overwrite=TRUE)

## 4.3 Calcul du facteur S------------------------------------------------------
teta_degrees <- rast("raster_slopes.tif")
teta_radiants <- teta_degrees*(pi/180) #Conversion des degrés en radiants car sin(x) fonctionne en radiants
S <- (65.41*((sin(teta_radiants))^2)) + (4.56*sin(teta_radiants)) + 0.065
writeRaster(S, "raster_S.tif", overwrite=TRUE)

##4.3 Calcul du facteur LS
LS <- L*S
plot(LS)
writeRaster(LS, "raster_LS.tif", overwrite=TRUE)






