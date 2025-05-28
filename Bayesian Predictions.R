library(dplyr)
library(tidyr)
library(INLA)
library(ggplot2)
library(Metrics)
library(sp)
library(caret)
library(pROC)
df<-read.csv("C:\\Users\\mnzilani\\Desktop\\Working Folder\\New Data\\Lags\\L3.csv")


# Add jitter to lat and lon
df <- df %>%
  mutate(
    lat_jittered = lat + runif(n(), -1e-5, 1e-5),
    lon_jittered = lon + runif(n(), -1e-5, 1e-5)
  )



# Define coordinates 
coords <- cbind(df$lat_jittered, df$lon_jittered)
# Set seed for reproducibility
set.seed(123)

# Split the data into training (80%) and testing (20%) sets
trainIndex <- createDataPartition(df$Infections, p = .8, list = FALSE, times = 1)
trainData <- df[trainIndex,]
testData <- df[-trainIndex,]

# Split coordinates accordingly
trainCoords <- coords[trainIndex, ]
testCoords <- coords[-trainIndex, ]

# Build the mesh for the training data
mesh_train <- inla.mesh.2d(loc = trainCoords, max.edge = c(0.5, 2), cutoff = 0.1)
plot(mesh_train)
points(trainCoords, col = "red", pch = 19)
spde_train <- inla.spde2.matern(mesh = mesh_train, alpha = 2)

# Generate index set for the mesh using training coordinates
A_train <- inla.spde.make.A(mesh_train, loc = trainCoords)
spde_index_train <- inla.spde.make.index(name = "spatial", n.spde = spde_train$n.spde)

# Prepare estimation stack (stk.e)
stk.e <- inla.stack(
  tag = "est",
  data = list(y = trainData$Infections, numtrials = rep(1, nrow(trainData))),  
  A = list(1, A_train),
  effects = list(data.frame(b0 = 1, 
                            tempmin = trainData$tempmin, 
                            NDVI = trainData$NDVI,
                            total_precip = trainData$total_precip,
                            population_density = trainData$population_density,
                            Distance_to_Water_km = trainData$Distance_to_Water_.km.,
                            LULC = trainData$LULC), 
                 spde_index_train)
)

# Load future dataset (without infection values)
future_df <- read.csv("C:\\Users\\mnzilani\\Downloads\\Turkana_Projection_data (1).csv")

# Define coordinates for the future dataset
future_coords <- cbind(future_df$lat, future_df$lon)

# Generate A matrix for future data using the training mesh
A_future <- inla.spde.make.A(mesh_train, loc = future_coords)

# Prepare prediction stack (stk.p)
stk.p <- inla.stack(
  tag = "pred",
  data = list(y = NA, numtrials = NA),
  A = list(1, A_future),
  effects = list(data.frame(b0 = 1, 
                            tempmin = future_df$tempmin, 
                            NDVI = future_df$NDVI,
                            total_precip = future_df$total_precip,
                            population_density = future_df$population_density,
                            Distance_to_Water_km = future_df$Distance_to_Water_.km.,
                            LULC = future_df$LULC), 
                 spde_index_train)
)
# Combine both stacks into one (stk.full)
stk.full <- inla.stack(stk.e, stk.p)

# Define the formula
formula <- y ~ b0 + tempmin + NDVI + total_precip + 
  population_density + Distance_to_Water_km + LULC + 
  f(spatial, model = spde_train)

# Fit the model on the combined stack
result <- inla(formula, family = "binomial", 
               data = inla.stack.data(stk.full),
               control.predictor = list(A = inla.stack.A(stk.full)),
               control.compute = list(dic = TRUE, waic = TRUE))

# View results
summary(result)

# Extract predictions from the result for prediction stack
predictions <- result$summary.fitted.values[inla.stack.index(stk.full, "pred")$data, "mean"]

predictions <- pnorm(predictions) 

# Ensure predictions are constrained between 0 and 1
predictions <- pmax(pmin(predictions, 1), 0)
# Check if predictions are between 0 and 1
summary(predictions)

# Create a data frame binding predictions with coordinates
results_df <- data.frame(
  lat = future_df$lat,
  lon = future_df$lon,
  predictions = predictions
)

# View the results
head(results_df)



