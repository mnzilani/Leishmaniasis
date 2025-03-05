
**README: Bayesian Spatial model**

Overview
The Bayesian full model 60 script implements a Bayesian Spatial model using the INLA (Integrated Nested Laplace Approximations) framework in R. It applies an SPDE (Stochastic Partial Differential Equation) model to predict infection outcomes based on various covariates and spatial information. The code includes steps for data preprocessing, model training, evaluation, and visualization.

**Requirements**

**Software**
R (R stduio)

Required packages:

dplyr (for data manipulation)

tidyr (to tidy messy data)

lNLA(for Bayesian modeling)

ggplot2(for visualization)

Metrics( for Evaluation)

sp( for classes and methods for spatial data)

caret( for data classification and regression training)

pROC(for ROC curve and AUC calculations)

readxl(for reading excel files)

**Input Data**

AGE: Numeric; age of individuals.

lat, lon: Numeric; latitude and longitude coordinates.

SEX: Categorical; sex of individuals.

Infections: Binary; infection status (1 = infected, 0 = not infected).

Temperature (tempmin)

Vegetation index (NDVI), 

Mean humidity, 

Total precipitation

Population density

Land use/land cover (LULC)

Distance to water bodies

Distance(Proximity to healthcare facilities)

Forest height ( canopy height)

Month( month of infection )

**Workflow**

**Step 1: Load and Prepare Data**

Load the dataset: The script imports a CSV file from a specified path.

Create age groups: Classifies ages into five groups: 0-5 years, 6-18 years, 19-30 years, 31-44 years, and 45 years and above.

Add spatial jittering: This process slightly modifies the latitude and longitude of points by a very small amount (1e-5 degrees) to address issues caused by duplicate coordinates. For example, in cases where multiple individuals are infected in the same village, all individuals would share the exact same geographic coordinates. However, our model doesn’t accept duplicate points. Applying jitter ensures that each individual has a unique set of coordinates while maintaining proximity to the original location. The jitter is small enough (1e-5 degrees) to ensure the points still represent the same village where the infections were recorded.

**Step 2: Split Data**
The data is split into training (80%) and testing (20%) sets using stratified sampling based on infection status.
Corresponding spatial coordinates are split similarly.
The set.seed(123) ensures reproducibility.

**Step 3: SPDE Mesh Construction**
Creates a triangular mesh using the training coordinates for spatial interpolation.
Constructs the SPDE model.

**Step 4: Model Fitting**
Fits a Bayesian model with covariates, random effects, and spatial dependency terms:
Fixed effects: SEX, distance, age_group, tempmin, NDVI, mean Humidty, Total precipitation, Population density, distance to water bodies, Forest height and LULC.
Random effects: spatial (SPDE model), month (IID random effect). Month represents the month of infection and it is added as a random effect to capture the variability of infections. From the EDA there is no specific pattern in the month of infections thus why it is fit as an IID random effect.
The model is fitted to the training data.

**Step 5: Model Evaluation**
Applies the trained model to the test data and computes:
Predicted probabilities
Binary classifications based on a 0.5 threshold
Confusion matrix, accuracy, precision, recall
ROC curve and AUC

**Step 6: Visualization**
Plots the ROC curve for the test data.
Displays the triangular mesh and training points.

**Key Outputs**

Model Summary: Displays fixed effects, random effects, DIC, and WAIC.
Confusion Matrix: Summarizes prediction accuracy on the test set.
Performance Metrics: Provides accuracy, precision, recall, and AUC.

Visualizations:
ROC curve for model evaluation.
Spatial mesh with training points.

**READ ME: MACHINE LEARNING MODELS**

**Requirements**

**Importing various libariries to help with data analytics and manipulation**

The libraries imported in this code are:

pandas (pd) - Data manipulation and analysis

matplotlib.pyplot (plt) - Plotting and visualization

matplotlib.cm (cm) - Colormap handling for visualization

seaborn (sns) - Statistical data visualization

numpy (np) - Numerical computations

sklearn.preprocessing.LabelEncoder - Encoding categorical labels

sklearn.model_selection.train_test_split - Splitting data into training and testing sets

sklearn.discriminant_analysis.StandardScaler - Feature scaling

sklearn.ensemble:

RandomForestClassifier - Ensemble learning with decision trees

AdaBoostClassifier - Adaptive boosting algorithm

ExtraTreesClassifier - Extreme randomized trees

BaggingClassifier - Bagging ensemble method

sklearn.tree.DecisionTreeClassifier - Decision tree model

sklearn.svm.SVC - Support Vector Classifier

sklearn.naive_bayes.GaussianNB - Naïve Bayes classifier

sklearn.linear_model.LogisticRegression - Logistic regression model

sklearn.metrics:

accuracy_score - Accuracy metric

precision_score - Precision metric

recall_score - Recall metric

f1_score - F1-score metric

roc_auc_score - ROC AUC metric

roc_curve - ROC curve computation

sklearn.model_selection.GridSearchCV - Hyperparameter tuning using grid search

!pip install shap - Installing the SHAP library (used for explainable AI and model interpretability)

**Workflow**

**Loading the DataSet and Looking at it**

 The dataset is loaded.
   
 There is a peak at the data types of the various features
 
 Correlation analysis is conducted to check the relationship between numerical variables.
**Modelling**

1. Eight models are fit to do machine learning analytics. The models are:
"Random Forest",

"Decision Tree",

"SVC",

"Naive Bayes",

"AdaBoost",

"Logistic Regression",

"Extra Trees",

"Bagging"

3. The features fed as independent variables into the models are:
        "SEX",
   
        "AGE",
   
        "distance",
   
        "population_density",
   
        "Distance_to_Water_.km.",
   
        "Elevation",
   
        "LULC",
   
        "tempmax",
   
        "tempmin",
   
        "mean_temp",
   
        "mean_humidity",
   
        "total_precip",
   
        "forest_height",
   
        "soil_type",
   
        "Brightness",
   
        "Greenness",
   
        "Wetness".
   
   The outcome variable is Infections.

5. The data is scaled and the hot encode is used to convert sex (categorical variable to numerical variable)
6. The scaled data is then split to training (80%) and test (20%)
7. The models are then evaluated based on performance metrics: accuracy, precision, F1-score,recall and AUC-ROC
8. The models are then hyperparamter tuned and the best lag and model selected based on the performance metrics
9. Seven best models are also selected based on the various performance metrics
10. SHAP analysis is conducted on the models: Bagging, adaboost. random forest, SVC and logistic regression.
11. Shap imprtance plots and feature plots are plotted.
12. The feature plots are broken down based on the classes of the outcome variable.
13. Hypertuuning of the models is repeated and done in 10 different runs and the best performing model and lag is selected from the 10 runs  


