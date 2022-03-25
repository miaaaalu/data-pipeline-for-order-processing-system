################################################
#########  Preparation
################################################

## install library 
> install.packages(c("ProjectTemplate", "reshape2", "tidyverse", "stringr", "lubridate", "dplyr", "pROC", "xgboost", "precrec"))

## Create project
> library('ProjectTemplate')
> create.project('letters')

## Source Importing 
move training data set to data/ directory 

## Library Configuration 
Open global.dcf file under config directory, add below libraries after libraries tag and save the file:
`reshape2`, `tidyverse`, `stringr`, `lubridate`, `dplyr`, `pROC`, `xgboost`, `precrec`

## Load Project
> library('ProjectTemplate')
> load.project()

################################################
#########  Feature Engineering
################################################
 
> data$prod_reorder_probability <- data$prod_second_orders / data$prod_first_orders
> data$prod_reorder_times <- 1 + data$prod_reorders / data$prod_first_orders
> data$prod_reorder_ratio <- data$prod_reorders / data$prod_orders
> data <- data %>% select(-prod_reorders, -prod_first_orders, -prod_second_orders)
> data$user_average_basket <- data$user_total_products / data$user_orders
> data$up_order_rate <- data$up_orders / data$user_orders
> data$up_orders_since_last_order <- data$user_orders - data$up_last_order
> data$up_order_rate_since_first_order <- data$up_orders / (data$user_orders - data$up_first_order + 1)

################################################
#########  Process DataFrames
################################################

# Create DataFrame 'us' with filter
> us <- orders %>%
    filter(eval_set != "prior") %>%
    select(user_id, order_id, eval_set)

# Join dataframe 'data' and 'us' 
> data <- data %>% 
    inner_join(us)

# Remove dataframe 'us'
> rm(us)

# Join dataframe 'order_products__train' and 'orders' 
> order.products.train <- order.products.train %>% 
    inner_join(orders[,c("order_id", "user_id")])

# Join dataframe 'order_products__train' and 'data' to create final dataset
> data <- data %>% 
    left_join(order.products.train %>% 
    select(user_id, product_id, reordered), 
                by = c("user_id", "product_id"))

#  Create DataFrame 'train' and 'test' by filter
> train <- data[data$eval_set == 'train',]
> test <- data[data$eval_set == "test",]

#  Remove irrelevant columns in Dataframe 'train'
> train$eval_set <- NULL
> train$user_id <- NULL
> train$product_id <- NULL
> train$order_id <- NULL

# Replace missing value with '0' in 'Train'
> train$reordered[is.na(train$reordered)] <- 0

#  Remove irrelevant columns in Dataframe 'test'
> test$eval_set <- NULL
> test$user_id <- NULL
> test$product_id <- NULL
> test$order_id <- NULL
> test$reordered <- NULL

################################################
#########  Modelling (Boosted Tree Xgboost)
################################################ 

# preparation 
set.seed(1)
train_bak <- train

# extract 10% sample set from Dataframe 'train'
train <- train[sample(nrow(train)),] %>% 
  sample_frac(0.1)

# Calling expand.grid() Function to set parameters
hyper_grid <-expand.grid(
  nrounds =               c(3000),
  max_depth =             c(6),
  eta =                   c(0.1),
  gamma =                 c(0.7),
  colsample_bytree =      c(0.95),
  subsample =             c(0.75),
  min_child_weight =      c(10),
  alpha =                 c(2e-05),
  lambda =                c(10),
  scale_pos_weight =      c(1)
)

nthread <- 6

# reading data by xgboost
train_data_x <- data.matrix(select(train, -reordered))  # response variable X
train_data_y <- data.matrix(select(train, reordered))   # predictor Y
train_data <- xgb.DMatrix(data = train_data_x, label = train_data_y)
test_data <- xgb.DMatrix(as.matrix(test))

# create watchlist to observe performance
watchlist <- list(train = train_data)
model_pos <- 1
set.seed(1)

# training model 
model <- xgb.train(
  data =                      train_data,
  
  nrounds =                   300,
  max_depth =                 hyper_grid[1, "max_depth"],
  eta =                       hyper_grid[1, "eta"],
  gamma =                     hyper_grid[1, "gamma"],
  colsample_bytree =          hyper_grid[1, "colsample_bytree"],
  subsample =                 hyper_grid[1, "subsample"],
  min_child_weight =          hyper_grid[1, "min_child_weight"],
  alpha =                     hyper_grid[1, "alpha"],
  lambda =                    hyper_grid[1, "lambda"],
  scale_pos_weight =          hyper_grid[1, "scale_pos_weight"],
  
  booster =                   "gbtree",
  objective =                 "binary:logistic",
  eval_metric =               "auc",
  prediction =                TRUE,
  verbose =                   TRUE,
  watchlist =                 watchlist,
  early_stopping_rounds =     50,
  print_every_n =             10,
  nthread =                   nthread
)

# predict training model 
pred_train_data <- predict(model, newdata = train_data_x)

# check the training performance
train_performance <- roc(as.vector(train_data_y), pred_train_data)
train_performance

# plot ROC curve and precision-recall curve
precrec_obj <- evalmod(scores = pred_train_data, labels = as.vector(train_data_y))
autoplot(precrec_obj)

# plot the probability distribution
df <- data.frame(scores = pred_train_data, labels = as.vector(train_data_y))
ggplot(df, aes(x=scores, fill=as.factor(labels))) + geom_density(alpha = 0.5)

################################################
#########  Cross-Validation
################################################ 

# 80% sample set to 'train', 20% to 'test'
train_index <- sample(1:nrow(train), 0.8 * nrow(train))

# Calling expand.grid() Function to set parameters
cat("Hypter-parameter tuning\n")
hyper_grid <-expand.grid(
  nrounds =               c(3000),
  objective =             c("binary:logistic"),
  eval_metric =           c("auc"),
  max_depth =             c(6),
  eta =                   c(0.1,0.05),
  gamma =                 c(0.7,0.05),
  colsample_bytree =      c(0.95),
  subsample =             c(0.75),
  min_child_weight =      c(10),
  alpha =                 c(2e-05),
  lambda =                c(10),
  scale_pos_weight =      c(1)
)

nthread <- 6

#  Cross-Validation training
for(i in 1:nrow(hyper_grid)){
  cat(paste0("\nModel ", i, " of ", nrow(hyper_grid), "\n"))
  cat("Hyper-parameters:\n")
  print(hyper_grid[i,])
  
  metricsValidComb <- data.frame()
  
  
  cv.nround = 100
  cv.nfold = 3
  mdcv <- xgb.cv(data=train_data, params = hyper_grid[i,], nthread=6, 
                 nfold=cv.nfold, nrounds=cv.nround,
                 verbose = T)
  
  model_auc = min(mdcv$evaluation_log$test_auc_mean)}

results_valid <- cbind(hyper_grid, final_valid_metrics)

# descending on AVG_AUC and get the best parameter
results_valid <- results_valid %>% 
  arrange(desc(AUC))

################################################
#########  Final Model
################################################ 

# reading data by xgboost
train_data_x <- data.matrix(select(train, -reordered))
train_data_y <- data.matrix(select(train, reordered))
train_data <- xgb.DMatrix(data = train_data_x, label = train_data_y)
test_data <- xgb.DMatrix(as.matrix(test)

model_pos <- 1
set.seed(1)

# training model 
model <- xgb.train(
  data =                      train_data,
  
  nrounds =                   cv.nround,
  max_depth =                 results_valid[model_pos, "max_depth"],
  eta =                       results_valid[model_pos, "eta"],
  gamma =                     results_valid[model_pos, "gamma"],
  colsample_bytree =          results_valid[model_pos, "colsample_bytree"],
  subsample =                 results_valid[model_pos, "subsample"],
  min_child_weight =          results_valid[model_pos, "min_child_weight"],
  alpha =                     results_valid[model_pos, "alpha"],
  lambda =                    results_valid[model_pos, "lambda"],
  scale_pos_weight =          results_valid[model_pos, "scale_pos_weight"],
  
  booster =                   "gbtree",
  objective =                 "binary:logistic",
  eval_metric =               "auc",
  prediction =                TRUE,
  verbose =                   TRUE,
  watchlist =                 watchlist,
  print_every_n =             10,
  nthread =                   nthread
)

# make a prediction on the training dataset
pred_train_data <- predict(model, newdata = train_data_x)
# check the performance of the model on training dataset
train_performance <- roc(as.vector(train_data_y), pred_train_data)

# plot ROC curve and precision-recall curve
precrec_obj <- evalmod(scores = pred_train_data, labels = as.vector(train_data_y))
autoplot(precrec_obj)


test$reordered <- predict(model, newdata = test_data)
test$reordered <- (test$reordered > 0.21) * 1

submission <- test %>%
  filter(reordered == 1) %>%
  group_by(order_id) %>%
  summarise(
    products = paste(product_id, collapse = " ")
  )

missing <- data.frame(
  order_id = unique(test$order_id[!test$order_id %in% submission$order_id]),
  products = "None"
)

submission <- submission %>% bind_rows(missing) %>% arrange(order_id)
write.csv(submission, file = "submit.csv", row.names = F)
