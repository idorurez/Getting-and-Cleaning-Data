run_analysis <- function () {
  
  library(data.table)
  library(dplyr)
  library(plyr)
  
  # various paths and filenames
  dir <- "data"
  
  dir_test <- paste(dir, "/", "test", sep="")
  dir_train <- paste(dir, "/", "train", sep="")
  
  fileName_exercise_labels <- "activity_labels.txt"
  fileName_features <- "features.txt"

  fileName_train_set <- "X_train.txt"
  fileName_train_labels <- "y_train.txt"
  
  fileName_test_set <- "X_test.txt"
  fileName_test_labels <- "y_test.txt"
  
  fileName_subjects_train <- "subject_train.txt"
  fileName_subjects_test <- "subject_test.txt"
  
  file_exercise_labels <- paste(dir,"/", fileName_exercise_labels, sep="")
  
  # read in list of exercises and assign them their corresponding index values
  labels <- read.table(file_exercise_labels, stringsAsFactors=FALSE, col.names=c("id", "exercise"))
  labels <- labels$exercise
  
  # build the paths
  file_features <- paste(dir, "/", fileName_features, sep="")
  
  file_train_subjects <- paste(dir_train, "/", fileName_subjects_train, sep="")
  file_train_set <- paste(dir_train, "/", fileName_train_set, sep="")
  file_train_labels <- paste(dir_train, "/", fileName_train_labels, sep="")
  
  file_test_subjects <- paste(dir_test, "/", fileName_subjects_test, sep="")
  file_test_set <- paste(dir_test, "/", fileName_test_set, sep="")
  file_test_labels <- paste(dir_test, "/", fileName_test_labels, sep="")
  
  # read in features
  features <- fread(file_features, col.names = c("id", "features"))
  
  # grep match string
  extractString <- "mean|std"
  
  # read in data for test group
  dt_test_subjects <- read.table(file_test_subjects, col.names = "subject_id")
  dt_test_set <- read.table(file_test_set, col.names = features[,features])
  dt_test_exercises <- fread(file_test_labels, col.names = "exercise")
  
  # read in data for train group
  dt_train_subjects <- read.table(file_train_subjects, col.names = "subject_id")
  dt_train_set <- read.table(file_train_set, col.names = features[,features])
  dt_train_exercises <- fread(file_train_labels, col.names = "exercise")
  
  # rename exercises to proper naming based on given activities list 
  dt_train_exercises[,exercise:=labels[exercise]]
  dt_test_exercises[,exercise:=labels[exercise]]
  
  #convert to data frame for usage downstream
  dt_train_exercises <- as.data.frame(dt_train_exercises)
  dt_test_exercises <- as.data.frame(dt_test_exercises)
  
  # convert strings to factors, so group_by can handle them
  dt_train_exercises$exercise <- as.factor(dt_train_exercises$exercise)
  dt_test_exercises$exercise <- as.factor(dt_test_exercises$exercise)
  
  #this is another way to cull out what we need, instead of using the plyr package
  #dt_train_set <- dt_train_set[,grep(extractString, names(dt_train_set))]
  #dt_test_set <- dt_test_set[,grep(extractString, names(dt_test_set))]
  
  # cull out
  dt_train_set <- select(dt_train_set, grep(extractString, names(dt_train_set)))
  dt_test_set <- select(dt_test_set, grep(extractString, names(dt_test_set)))
  
  
  train_rows <- seq(1:nrow(dt_train_subjects))
  test_rows <- seq(1:nrow(dt_test_subjects))
  
  # add row id
  dt_test_subjects$id <- test_rows
  dt_test_set$id <- test_rows
  dt_test_exercises$id <- test_rows
  
  # add row id
  dt_train_subjects$id <- train_rows
  dt_train_set$id <- train_rows
  dt_train_exercises$id <- train_rows
  
  # list of all of the data frmes we want to merge
  train_list <- list(dt_train_subjects, dt_train_exercises, dt_train_set)
  test_list <- list(dt_test_subjects, dt_test_exercises, dt_test_set)
  
  # merge all 
  dt_train_data <- join_all(train_list, by="id")
  dt_test_data <-  join_all(test_list, by="id")
  prelim_data <- rbind(dt_train_data,dt_test_data)
  
  # drop id and we have our semi-raw data
  prelim_data$id <- NULL
  
  # now group by person, exercise, and then the mean and return

  tidy_data <- prelim_data %>% group_by(subject_id, exercise) %>% summarize_each(funs(mean))

  write.table(tidy_data, file="tidy_data.txt", row.name=FALSE)
  
  return(tidy_data) 
 
}