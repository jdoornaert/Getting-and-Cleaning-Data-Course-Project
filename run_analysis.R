# clean up environment
rm(list = ls())

# define root folder (under which we will create a folder to manage the data)
rootfolder <- "/home/jdo/Coursera"

# define data folder (folder to be created under the root folder to hold the data)
datafolder <- "./data"

# select working directory
setwd(dir = rootfolder)
if (!file.exists(datafolder)) { dir.create(datafolder) }
setwd(datafolder)

# retrieve zipped data file, unzip
#download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", dest = "UCI HAR Dataset.zip")
#unzip(zipfile = "UCI HAR Dataset.zip", overwrite = FALSE)

# enter data hierarchy, extract metadata
setwd(dir = "./UCI HAR Dataset")
variable_names <- read.table(file = "features.txt", header = FALSE, stringsAsFactors = FALSE, sep = " ", colClasses = c("NULL", NA))
variable_names <- as.vector(variable_names$V2)
activity_labels <- read.table(file = "activity_labels.txt", header = FALSE, stringsAsFactors = FALSE, sep = " ", col.names = c("Activity_Id", "Activity"))

# enter data hierarchy - test data, get raw data and metadata (activity and subject information)
setwd(dir = "./test")
X_test <- read.table(file = "X_test.txt", header = FALSE, stringsAsFactors = FALSE, sep = "")
names(X_test) <- variable_names
y_test <- read.table(file = "y_test.txt", header = FALSE, stringsAsFactors = FALSE, sep = "", col.names = c("Activity_Id"))
y_test <- merge(y_test, activity_labels, by = "Activity_Id")
y_test$Activity_Id <- NULL
y_test$Activity <- as.factor(y_test$Activity)
subject_test <- read.table(file = "subject_test.txt", header = FALSE, stringsAsFactors = TRUE, sep = "", col.names = c("Subject"))
X_test <- cbind(subject_test, y_test, X_test)

# enter data hierarchy - training data, get raw data and metadata (activity and subject information)
setwd(dir = "../train")
X_train <- read.table(file = "X_train.txt", header = FALSE, stringsAsFactors = FALSE, sep = "")
names(X_train) <- variable_names
y_train <- read.table(file = "y_train.txt", header = FALSE, stringsAsFactors = FALSE, sep = "", col.names = c("Activity_Id"))
y_train <- merge(y_train, activity_labels, by = "Activity_Id")
y_train$Activity_Id <- NULL
y_train$Activity <- as.factor(y_train$Activity)
subject_train <- read.table(file = "subject_train.txt", header = FALSE, stringsAsFactors = TRUE, sep = "", col.names = c("Subject"))
X_train <- cbind(subject_train, y_train, X_train)

# merge test and train data frames
df <- rbind(X_test, X_train)

# select columns with subject and activity information and with mean and standard deviation measurements
df_select <- df[,grep("Subject|Activity|mean\\(\\)|std\\(\\)", names(df))]

# tidy up the column names a bit
names(df_select) <- tolower(names(df_select))
names(df_select) <- sub("\\(\\)", "", names(df_select))

# cleanup
rm(y_test, subject_test, y_train, subject_train, activity_labels, variable_names, X_test, X_train, df)

# ...and return to the default working directory
setwd(dir = rootfolder)
