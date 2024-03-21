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
library(stars)

# ******************************************************************************
# 2. Importer les données ------------------------------------------------------
# ******************************************************************************
#outlets or points-of-interest (exutoire d'un lac)
lake_outlet <-  vect("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/LacGale_exutoire.shp")
crs <- crs(lake_outlet)
#DEM
DEM_path <- "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/Watersheds/MNT_31H07SE.tif"
DEM <- rast(DEM_path)
DEM <- project(DEM, crs)
# Print information about the raster
print(DEM)

# ******************************************************************************
# 3. Watershed delineation -----------------------------------------------------
# ******************************************************************************
setwd("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Programmation/R/Data/Watersheds")

# 3.1 Prepare DEM for Hydrology Analyses----------------------------------------
wbt_breach_depressions_least_cost(
  dem = DEM,
  output = "MNT_31H07SEdem_breached.tif",
  dist = 5000,
  fill = TRUE)

wbt_fill_depressions_wang_and_liu(
  dem = "MNT_31H07SEdem_breached.tif",
  output = "MNT_31H07SEdem_breachedfilled_breached.tif"
)
# 3.2 Create flow accumulation and pointer grids -------------------------------
#The flow accumulation grid is a raster where each cell is the area that drains to that cell
wbt_d8_flow_accumulation(input = "MNT_31H07SEdem_breachedfilled_breached.tif",
                         output = "MNT_31H07SEdem-D8FA.tif")
#The pointer file is a raster where each cell has a value that specifies which direction water would flow downhill away from that cell.
wbt_d8_pointer(dem = "MNT_31H07SEdem_breachedfilled_breached.tif",
               output = "MNT_31H07SEdem-D8pointer.tif")

# 3.3 Setting pour point--------------------------------------------------------

wbt_extract_streams(flow_accum = "MNT_31H07SEdem-D8FA.tif",
                    output = "MNT_31H07SEdem-raster_streams.tif",
                    threshold = 6000)

wbt_jenson_snap_pour_points(pour_pts = lake_outlet,
                            streams = "MNT_31H07SEdem-raster_streams.tif",
                            output = "MNT_31H07SEdem-snappedpp.shp",
                            snap_dist = 0.0005) #careful with this! Know the units of your data

#Attention, si ça ne fonctionne pas, remettre le point (pour point) directement sur un stream à partir d'un logiciel SIG
pp <- vect("MNT_31H07SEdem-snappedpp.shp")
streams <- rast("MNT_31H07SEdem-raster_streams.tif")

# 3.4 Delineate watersheds------------------------------------------------------

wbt_watershed(d8_pntr = "MNT_31H07SEdem-D8pointer.tif",
              pour_pts = "MNT_31H07SEdem-snappedpp.shp",
              output = "MNT_31H07SEdem-brush_watersheds.tif")

ws <- rast("MNT_31H07SEdem-brush_watersheds.tif")

# 3.5 Convert watersheds to shapefile-------------------------------------------

ws_shape <- as.polygons(ws)
writeVector(ws_shape, "Watershed.shp", overwrite=FALSE)
