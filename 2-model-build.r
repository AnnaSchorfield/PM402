model_board <- board_folder("models/", versioned  = TRUE)

# Setting control parameters
ctrl <- trainControl(method = "cv",
number = 5,
classProbs = TRUE,
summaryFunction = twoClassSummary,
savePredictions = TRUE)

# Setting seed so that same results are yielded
set.seed(999)

# Training model (glm)
lr_caret <- train(
  churn ~.,
  data = churn_train,
  method = "glmnet",
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(
    alpha = c(0,0.5,1),
    lambda = c(0.001,0.01,0.1,1)
  )
)
lr_caret

# Training model (random forest)
rf_caret <- train(
  churn ~.,
  data = churn_train,
  method = "rf",
  trControl = ctrl,
  metric = "ROC",
  tuneGrid = expand.grid(
    mtry = c(2,4,6)
  )
)
rf_caret

# Create a "league table" of model results using the pins package
pin_write(
  model_board,
  lr_caret, # Model
  name = "churn_model_caret",
  metadata = list( # Choosing what to save down
    method = "lr", # logistic regression
    cv_row = max(lr_caret$results$ROC),
    cv_sens = max(lr_caret$results$Sens), # Sensitivity
    cv_spec = max(lr_caret$results$Spec), # Specificity
    best_tune_str = paste0( # Best tuning parameters
      "alpha: ", lr_caret$bestTune$alpha,
      ", lambda: ",lr_caret$bestTune$lambda
    ),
  n_train = nrow(churn_train)
)
)

pin_write(
  model_board,
  rf_caret, # Model
  name = "churn_model_caret",
  metadata = list( # Choosing what to save down
    method = "rf", # random forest
    cv_row = max(rf_caret$results$ROC),
    cv_sens = max(rf_caret$results$Sens), # Sensitivity
    cv_spec = max(rf_caret$results$Spec), # Specificity
    best_tune_str = paste0( # Best tuning parameters
      "mtry: ", rf_caret$bestTune$mtry
    ),
  n_train = nrow(churn_train)
)
)

versions <- pin_versions(model_board, "churn_model_caret") # Writing out the number of versions

# Creating final output table
league_table <- 
  purrr::map_dfr(versions$version,function(v) {
  meta <- pin_meta(model_board, "churn_model_caret", version = v)
  tibble::tibble(
    version = v,
    method = meta$user$method,
    cv_roc = meta$user$cv_roc,
    cv_sens = meta$user$cv_sens,
    cv_spec = meta$user$cv_spec,
    best_tune_str = meta$user$best_tune_str,
    n_train = meta$user$n_train
  )
})

league_table

saveRDS(league_table, "league_table.rdata")
