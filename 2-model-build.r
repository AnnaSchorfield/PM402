model_board <- board_folder("models/", versioned  = TRUE)

# Setting control parameters
ctrl <- trainControl(method = "cv",
number = 5,
classProbs = TRUE,
summaryFunction = twoClassSummary,
savePredictions = TRUE)

# Setting seed so that same results are yielded
set.seed(999)

# Training model
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
