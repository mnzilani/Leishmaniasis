# Load necessary libraries
library(gstat)
library(sp)
library(raster)
install.packages("rgdal")
library(sf)

data <- read.csv("C:\\Users\\mnzilani\\OneDrive - INTERNATIONAL CENTRE OF INSECT PHYSIOLOGY AND ECOLOGY (ICIPE)\\Downloads\\future_infection_predictions (1).csv")

# Prepare the spatial data
coordinates(data) <- ~lon+lat



# Read the shapefile
shapefile <- st_read("C:\\Users\\mnzilani\\OneDrive - INTERNATIONAL CENTRE OF INSECT PHYSIOLOGY AND ECOLOGY (ICIPE)\\Desktop\\Article\\Maureen_Leshmaniasis\\Maureen_Leshmaniasis\\AOI\\Turkana.shp")
# Define the spatial extent and resolution for the output raster
extent <- extent(shapefile)
res <- 1 / 111  # 1 km in degrees (approx)

# Create an empty raster with the specified resolution
raster_template <- raster(extent, res=res)

# Perform the IDW interpolation using the 'prediction1' column
idw_output <- idw(formula = Predictions1 ~ 1, locations = data, newdata = as(raster_template, "SpatialGridDataFrame"))

# Convert the IDW output to a raster
idw_raster <- raster(idw_output)

# Clip the result to the shapefile extent
idw_raster_clipped <- mask(idw_raster, shapefile)

# Save the result as a raster file

writeRaster(idw_raster_clipped, 'idw_model_raster.tif', format='GTiff', overwrite=TRUE)

