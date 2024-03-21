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

# Set working directory
setwd("C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/A results/Sous-bassins")

# Define raster file names
raster_files <- c("Coulée_du_rocher.tif", "Ruisseau_Wright.tif", "Ruisseau_petit_galop.tif", "Ruisseau_des_cervidés.tif", 
                  "Residuel_nord.tif", "Residuel_nord_est.tif", "Residuel_nord_ouest.tif", "Residuel_sud_est.tif", "Residuel_sud_ouest.tif")

# ******************************************************************************
# 3. Traiter les données matricielles ------------------------------------------
# ******************************************************************************
# Load raster datasets
rasters <- lapply(raster_files, function(file) rast(file))
rasters <- lapply(rasters, function(r) r / 10000)

# Filter negative values and convert to vector
filtered_rasters <- lapply(rasters, function(r) clamp(r, 0, Inf))
vector_rasters <- lapply(filtered_rasters, as.vector)

# Calculate sum and mean for each raster
stats <- lapply(vector_rasters, function(v) {
  sum_val <- sum(v, na.rm = TRUE)
  mean_val <- mean(v, na.rm = TRUE)
  list(sum = sum_val, mean = mean_val)
})
# ******************************************************************************
# 4. Données des bassins versants ----------------------------------------------
# ******************************************************************************
# Define shapefile path
shapefile_path <- "C:/Users/gaelm/OneDrive - USherbrooke/UdeS/Maîtrise/Bromont/Watersheds/Sous_bassins_lacBromont/sous_bassins_lac_bromont.shp"

# Read shapefile
watersheds <- st_read(shapefile_path)

# Define watershed names

watershed_names <- c("Coulée du Rocher","Ruisseau Wright", "Ruisseau Petit Galop", "Ruisseau des Cervidés", "Résiduel Nord", 
                     "Résiduel Nord-Est", "Résiduel Nord-Ouest", "Résiduel Sud-Est",  "Résiduel Sud-Ouest")

# Filter watersheds and extract area
waterstats <- lapply(watershed_names, function(name) {
  ws <- watersheds[watersheds$Nom == name, ]
  m2 <- (ws$km2) * 1000000
  list(watershed = ws, m2 = m2)
})
# ******************************************************************************
# 5. Statistiques des bassins versants -----------------------------------------
# ******************************************************************************

raster_data <- data.frame(
  Raster = raster_files,
  Sum = sapply(stats, function(x) x$sum),
  Mean = sapply(stats, function(x) x$mean)
)

# Create data frame for watershed statistics
watershed_data <- data.frame(
  Watershed = watershed_names,
  Area_m2 = sapply(waterstats, function(x) x$m2)
)

# Combine raster and watershed data
combined_data <- cbind(raster_data, watershed_data)

# Calculate "OverArea" and add it to the combined data frame
combined_data$OverArea <- combined_data$Sum / combined_data$Area_m2

# Write combined data to CSV
write.csv(combined_data, "combined_statistics.csv", row.names = FALSE)


