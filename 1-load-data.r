# Loading in dataset
data(mlc_churn)
# head(mlc_churn)

set.seed(999)

# Create train and test data

bound <- nrow(mlc_churn)*0.75 # Want 75% of data for training

mlc_churn <- mlc_churn[sample(nrow(mlc_churn)),] # Sample data
churn_train <- mlc_churn[1:bound,] # Training data
churn_test <- mlc_churn[(bound+1):nrow(mlc_churn),] # Testing data

saveRDS(churn_test,"churn_test.rds") # Saving test data
