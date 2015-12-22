# Getting and Cleaning Data Course Project - CodeBook

## Introduction

This document describes and explains the contents of the file `run_analysis.R`, which you will find in this repository.

## Code

Let's start, then... And starting we do with a clean slate:

`# clean up environment`  
`rm(list = ls())`

Next up we load the required packages - in this case, that's just *dplyr*:

`# required libraries: dplyr`  
`library(dplyr)`

Then, a number of constants are defined for later use - the comments are self-explanatory:

`# constant: data set download URL`  
`datasetURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"`

`# constant: data set file name`  
`datasetfilename <- "UCI HAR Dataset.zip"`

`# constant: root folder (location of the zipped data set)`  
`rootfolder <- getwd()`

`# constant: output file name (final dataset)`  
`outputfile <- "output.txt"`

If the zipped data file is not present, we'll download it (unzipping is done always, but if present, the data is not overwritten):

`# get zipped data set if not present yet and unzip`  
`if (!file.exists(datasetfilename)) { download.file(url = datasetURL, dest = datasetfilename) }`  
`unzip(zipfile = "UCI HAR Dataset.zip", overwrite = FALSE)`

Now we get to the meat of the code: navigate to the *test* and *train* folders and read the data into a data frame:

`# retrieve "test" part of the data set in a data frame`  
`setwd(dir = file.path(rootfolder, "UCI HAR Dataset/test"))`  
`X_test <- tbl_df(read.table(file = "X_test.txt", header = FALSE, stringsAsFactors = FALSE, sep = ""))`

`# retrieve "train" part of the data set in a data frame`  
`setwd(dir = file.path(rootfolder, "UCI HAR Dataset/train"))`  
`X_train <- tbl_df(read.table(file = "X_train.txt", header = FALSE, stringsAsFactors = FALSE, sep = ""))`

...and then stitch it together (and clean up unnnecessary environment variables):

`# concatenate the "test" and "train" data frames and clean up (part 1 of the project)`  
`X_merged <- rbind(X_test, X_train)`  
`rm(X_test, X_train)`

Without metadata, data is useless. We only need the columns/variables that are the mean and standard deviation of measurements.  
Let's get the column/variable names from the **features.txt** file and use those to prune the data frame (and in one fell swoop,  
name the columns/variables of the data frame):

`# retrieve the variable names, find the ones pertaining to the mean and standard deviation`  
`# use these to select the required columns/variables from the merged data frame (part 2 of the project)`  
`# name those columns/variables appropriately and clean up (part 4 of the project)`  
`setwd(dir = file.path(rootfolder, "UCI HAR Dataset"))`  
`variable_names <- as.vector(read.table(file = "features.txt", header = FALSE, stringsAsFactors = FALSE, sep = " ", colClasses = c("NULL", NA))[,1])`  
`variables_ok <- grepl("mean\\(\\)|std\\(\\)", variable_names)`  
`variable_names <- variable_names[variables_ok]`  
`X_merged <- X_merged[, variables_ok]`  
`names(X_merged) <- variable_names`  
`#names(X_merged) <- tolower(names(X_merged))`  
`#names(X_merged) <- sub("\\(\\)", "", names(X_merged))`  
`rm(variable_names, variables_ok)`

**Remark:** the commented-out lines make the column names somewhat more tidy (lower case, no brackets). Uncomment at will...

Back to the script, now: let's also get the activities of the subjects (split over the *test* and *train* folders again...) and tack it onto our data frame:

`# retrieve the activities and subjects from the "test" and "train" parts of the data set`  
`# concatenate them, merge them with the main data frame and clean up`  
`setwd(dir = file.path(rootfolder, "UCI HAR Dataset/test"))`  
`y_test <- tbl_df(read.table(file = "y_test.txt", header = FALSE, stringsAsFactors = FALSE, sep = "", col.names = c("Activity_Id")))`  
`subject_test <- tbl_df(read.table(file = "subject_test.txt", header = FALSE, stringsAsFactors = TRUE, sep = "", col.names = c("Subject")))`

`setwd(dir = file.path(rootfolder, "UCI HAR Dataset/train"))`  
`y_train <- tbl_df(read.table(file = "y_train.txt", header = FALSE, stringsAsFactors = FALSE, sep = "", col.names = c("Activity_Id")))`  
`subject_train <- tbl_df(read.table(file = "subject_train.txt", header = FALSE, stringsAsFactors = TRUE, sep = "", col.names = c("Subject")))`

`X_merged <- cbind(X_merged, rbind(y_test, y_train), rbind(subject_test, subject_train))`  
`rm(y_test, subject_test, y_train, subject_train)`

One last thing - the activities are just numbers now, but using the **activity_labels.txt** file, we can provide some more descriptive values:

`# retrieve the descriptive labels for the activities`  
`# and use it to convert the "Activity_Id" column to an "Activity" column and clean up (part 3 of the project)`  
`setwd(dir = file.path(rootfolder, "UCI HAR Dataset"))`  
`activity_labels <- tbl_df(read.table(file = "activity_labels.txt", header = FALSE, stringsAsFactors = FALSE, sep = " ", col.names = c("Activity_Id", "Activity")))`  
`X_merged <- merge(X_merged, activity_labels, by = "Activity_Id")`  
`X_merged$Activity_Id <- NULL`  
`rm(activity_labels)`

Finally, let's calculate the required summary date (mean of all variables, grouped by activity and subject):

`# calculate mean of all variables, grouped by activity and subject, ordered by the group by columns (part 5 of the project)`  
`X_final <- X_merged %>% group_by(Activity, Subject) %>% summarise_each(funs(mean)) %>% arrange(Activity, Subject)`  
`rm(X_merged)`

As a bonus, we write the final data frame to a file:

`# write output`  
`setwd(dir = rootfolder)`  
`write.table(X_final, outputfile, row.names = FALSE)`

...and that's it!

## Results

The end result, *X_final*, is a data frame containing 180 observations of 68 variables. 180 observations, because there are 30 subjects (only known by their number - 1:30) and 6 activities:

* LAYING
* SITTING
* STANDING
* WALKING
* WALKING_DOWNSTAIRS
* WALKING_UPSTAIRS

The 66 other variables (excluding *Activity* and *Subject*) are the ones from the original data set that are either a mean (*mean()*) or standard deviation (*std()*) - I refer the reader to the **README.txt** and **features_info.txt** files in the original data set for more information.  
The values that are in the *X_final* data frame are the averages of these variables grouped per activity and subject.

Here's a list of those variables:

* tBodyAcc-mean()-X  
* tBodyAcc-mean()-Y  
* tBodyAcc-mean()-Z  
* tBodyAcc-std()-X  
* tBodyAcc-std()-Y  
* tBodyAcc-std()-Z  
* tGravityAcc-mean()-X  
* tGravityAcc-mean()-Y  
* tGravityAcc-mean()-Z  
* tGravityAcc-std()-X  
* tGravityAcc-std()-Y  
* tGravityAcc-std()-Z  
* tBodyAccJerk-mean()-X  
* tBodyAccJerk-mean()-Y  
* tBodyAccJerk-mean()-Z  
* tBodyAccJerk-std()-X  
* tBodyAccJerk-std()-Y  
* tBodyAccJerk-std()-Z  
* tBodyGyro-mean()-X  
* tBodyGyro-mean()-Y  
* tBodyGyro-mean()-Z  
* tBodyGyro-std()-X  
* tBodyGyro-std()-Y  
* tBodyGyro-std()-Z  
* tBodyGyroJerk-mean()-X  
* tBodyGyroJerk-mean()-Y  
* tBodyGyroJerk-mean()-Z  
* tBodyGyroJerk-std()-X  
* tBodyGyroJerk-std()-Y  
* tBodyGyroJerk-std()-Z  
* tBodyAccMag-mean()  
* tBodyAccMag-std()  
* tGravityAccMag-mean()  
* tGravityAccMag-std()  
* tBodyAccJerkMag-mean()  
* tBodyAccJerkMag-std()  
* tBodyGyroMag-mean()  
* tBodyGyroMag-std()  
* tBodyGyroJerkMag-mean()  
* tBodyGyroJerkMag-std()  
* fBodyAcc-mean()-X  
* fBodyAcc-mean()-Y  
* fBodyAcc-mean()-Z  
* fBodyAcc-std()-X  
* fBodyAcc-std()-Y  
* fBodyAcc-std()-Z  
* fBodyAccJerk-mean()-X  
* fBodyAccJerk-mean()-Y  
* fBodyAccJerk-mean()-Z  
* fBodyAccJerk-std()-X  
* fBodyAccJerk-std()-Y  
* fBodyAccJerk-std()-Z  
* fBodyGyro-mean()-X  
* fBodyGyro-mean()-Y  
* fBodyGyro-mean()-Z  
* fBodyGyro-std()-X  
* fBodyGyro-std()-Y  
* fBodyGyro-std()-Z  
* fBodyAccMag-mean()  
* fBodyAccMag-std()  
* fBodyBodyAccJerkMag-mean()  
* fBodyBodyAccJerkMag-std()  
* fBodyBodyGyroMag-mean()  
* fBodyBodyGyroMag-std()  
* fBodyBodyGyroJerkMag-mean()  
* fBodyBodyGyroJerkMag-std()  
