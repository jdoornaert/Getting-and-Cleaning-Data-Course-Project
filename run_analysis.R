# clean up environment
rm(list = ls())

# required libraries: dplyr
library(dplyr)

# constant: data set download URL
datasetURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# constant: data set file name
datasetfilename <- "UCI HAR Dataset.zip"

# constant: root folder (location of the zipped data set)
rootfolder <- getwd()

# constant: output file name (final dataset)
outputfile <- "output.txt"

# get zipped data set if not present yet and unzip
if (!file.exists(datasetfilename)) { download.file(url = datasetURL, dest = datasetfilename) }
unzip(zipfile = "UCI HAR Dataset.zip", overwrite = FALSE)

# retrieve "test" part of the data set in a data frame
setwd(dir = file.path(rootfolder, "UCI HAR Dataset/test"))
X_test <- tbl_df(read.table(file = "X_test.txt", header = FALSE, stringsAsFactors = FALSE, sep = ""))

# retrieve "train" part of the data set in a data frame
setwd(dir = file.path(rootfolder, "UCI HAR Dataset/train"))
X_train <- tbl_df(read.table(file = "X_train.txt", header = FALSE, stringsAsFactors = FALSE, sep = ""))

# concatenate the "test" and "train" data frames and clean up (part 1 of the project)
X_merged <- rbind(X_test, X_train)
rm(X_test, X_train)

# retrieve the variable names, find the ones pertaining to the mean and standard deviation
# use these to select the required columns/variables from the merged data frame (part 2 of the project)
# name those columns/variables appropriately and clean up (part 4 of the project)
setwd(dir = file.path(rootfolder, "UCI HAR Dataset"))
variable_names <- as.vector(read.table(file = "features.txt", header = FALSE, stringsAsFactors = FALSE, sep = " ", colClasses = c("NULL", NA))[,1])
variables_ok <- grepl("mean\\(\\)|std\\(\\)", variable_names)
variable_names <- variable_names[variables_ok]
X_merged <- X_merged[, variables_ok]
names(X_merged) <- variable_names
#names(X_merged) <- tolower(names(X_merged))
#names(X_merged) <- sub("\\(\\)", "", names(X_merged))
rm(variable_names, variables_ok)

# retrieve the activities and subjects from the "test" and "train" parts of the data set
# concatenate them, merge them with the main data frame and clean up
setwd(dir = file.path(rootfolder, "UCI HAR Dataset/test"))
y_test <- tbl_df(read.table(file = "y_test.txt", header = FALSE, stringsAsFactors = FALSE, sep = "", col.names = c("Activity_Id")))
subject_test <- tbl_df(read.table(file = "subject_test.txt", header = FALSE, stringsAsFactors = TRUE, sep = "", col.names = c("Subject")))

setwd(dir = file.path(rootfolder, "UCI HAR Dataset/train"))
y_train <- tbl_df(read.table(file = "y_train.txt", header = FALSE, stringsAsFactors = FALSE, sep = "", col.names = c("Activity_Id")))
subject_train <- tbl_df(read.table(file = "subject_train.txt", header = FALSE, stringsAsFactors = TRUE, sep = "", col.names = c("Subject")))

X_merged <- cbind(X_merged, rbind(y_test, y_train), rbind(subject_test, subject_train))
rm(y_test, subject_test, y_train, subject_train)

# retrieve the descriptive labels for the activities
# and use it to convert the "Activity_Id" column to an "Activity" column and clean up (part 3 of the project)
setwd(dir = file.path(rootfolder, "UCI HAR Dataset"))
activity_labels <- tbl_df(read.table(file = "activity_labels.txt", header = FALSE, stringsAsFactors = FALSE, sep = " ", col.names = c("Activity_Id", "Activity")))
X_merged <- merge(X_merged, activity_labels, by = "Activity_Id")
X_merged$Activity_Id <- NULL
rm(activity_labels)

# calculate mean of all variables, grouped by activity and subject, ordered by the group by columns (part 5 of the project)
X_final <- X_merged %>% group_by(Activity, Subject) %>% summarise_each(funs(mean)) %>% arrange(Activity, Subject)
rm(X_merged)

# write output
setwd(dir = rootfolder)
write.table(X_final, outputfile, row.names = FALSE)
