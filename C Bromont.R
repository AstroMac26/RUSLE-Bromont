# ******************************************************************************
# 1. Environnement de travail --------------------------------------------------
# ******************************************************************************
## Nettoyage l'environnement de travail
rm(list=ls())

# Load required libraries
library(terra)

# ******************************************************************************
# 2. Importer les données ------------------------------------------------------
# ******************************************************************************
#On va définir le raster de NDVI déjà calculé
ndvi <- rast("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/C factor/NDVI_final.tif")

# ******************************************************************************
# 3. Calculer le facteur C -----------------------------------------------------
# ******************************************************************************
#On calcule le raster du facteur C avec la formule de Van et al. (2000)
C <- exp(-2 * (ndvi / (1 - ndvi)))
#McFarlane et al. (1991)
C2 <- (-1.21*ndvi)+1.02

#On écrit le résultat
writeRaster(C, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/C factor/C_factor.tif", overwrite=TRUE)
writeRaster(C2, "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/C factor/C2_factor.tif", overwrite=TRUE)

