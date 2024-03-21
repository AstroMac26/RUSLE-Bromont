# ******************************************************************************
# 1. Environnement de travail --------------------------------------------------
# ******************************************************************************
## Nettoyage l'environnement de travail
rm(list=ls())

# Load required libraries
library(terra)
library(sp)
library(sf)
library(tmap)

# ******************************************************************************
# 2. Importer les données ------------------------------------------------------
# ******************************************************************************

#On va assigner chacun des paramètres à une varaible sous forme matricielle ou numérique
C <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/C factor/C_factor.tif")
C2 <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/C factor/C2_factor.tif")
P <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/P factor/Facteur_P.tif")
K <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/K factor/K_factor.tif")
R <- 1154.07432 # Considérant que R est constant pour l'ensemble du Bassin versant
LS <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/LS factor/raster_LS.tif")

#Pour mettre en commun les facteurs, il faut que ceux-ci aient la même étendue géographique et le même systèmes de coordonnées
Bassin_versant <-  st_read("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Baccalauréat/Session 4/APP/Données/Données de base utiles pour carto/Bassin versant/Bassin versant Lac Bromont/Bassin_versant_lac_bromont.shp")
crs <- crs(Bassin_versant)

# Reprojeter les différents rasters en fonction du crs du Bassin Versant
C <- project(C, crs)
C2 <- project(C2, crs)
P <- project(P, crs)
K <- project(K, crs)
LS <- project(LS, crs)

# Rééchantillone des rasters pour pouvoir les combiner ensemble, dans ce cas-ci, on rééchantillone selon LS (qui possède la meilleure résolution)
C <- resample(C, LS)
C2 <- resample(C2, LS)
P <- resample(P, LS)
K <- resample(K, LS)


# ******************************************************************************
# 3. Calcul du A ---------------------------------------------------------------
# ******************************************************************************

A <- C*P*K*LS*R
A2 <- C2*P*K*LS*R
A2noP <- C2*K*LS*R
A3 <- C2*K*LS*R
AK <- CK*PK*LSK*K*R 
AsansC <- P*K*LS*R

#réécrire les rasters
writeRaster(A, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A_R1.tif", overwrite=TRUE)
writeRaster(A2, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A_R2.tif", overwrite=TRUE)
writeRaster(A3, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A_R3.tif", overwrite=TRUE)
writeRaster(AK, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A_K.tif", overwrite=TRUE)
writeRaster(AsansC, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/AsansC.tif", overwrite=TRUE)
writeRaster(A2noP, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/A2noP.tif", overwrite=TRUE)






