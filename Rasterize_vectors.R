# ******************************************************************************
# 1. Environnement de travail --------------------------------------------------
# ******************************************************************************
## Nettoyage l'environnement de travail
rm(list=ls())
# Load required libraries
#library(raster)
library(tmap)
library(sp)
library(sf)
library(stars)
library(terra)

# ******************************************************************************
# 2. Importer les données ------------------------------------------------------
# ******************************************************************************

# Lire le shapefile avec tmap
polygon <-  st_read("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/K factor/Carte_pedo/Pedo_31H07102.shp")
plot(polygon)
# ******************************************************************************
# 3. Traiter les données ------------------------------------------------------
# ******************************************************************************

rasterized <- st_rasterize(polygon, st_as_stars(st_bbox(polygon), nx = 8000, ny = 8000, values = NA_real_)) #Na_real_ so attribute not specified, but make sure the attribute you want to rasterise is the only real/double format field

#Write the final result
write_stars(rasterized,"C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/K factor/K_factor_Gale.tif")
