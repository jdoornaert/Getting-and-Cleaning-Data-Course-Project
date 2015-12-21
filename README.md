# Getting and Cleaning Data Course Project - README

## Introduction

This project involves the transformation of a data set collected from the accelerometers from Samsung Galaxy S smartphones.  
You can find the original data set [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), documentation about the experiment where the data set was obtained from can be found [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

*****

You will notice right away that the data set zip file contains sub-folders called *test* and *train*.  
These folders contain 30% and 70% of the data set, respectively, the intention being to use the *train* data to set up a model that can subsequently be tested through the *test* data.  
For this project, this split data set provides an excellent opportunity to hone our merging skills.  

*****

You will also notice that the *test* and *train* folders both contain a sub-folder *Inertial Signals* that contains the raw data from the experiment.  
For this project, we are not interested in this raw data, but rather in the files stored directly under the *test* and *train* folders themselves (and those in the root folder of the zip file).  
These files contain preprocessed sensor data from the raw data - more information about how this processing was done can be found in the **README.txt** file that can be found in the root folder of the zip file. In this file, there is also a short description of the other files in the data set zip file and thus worth a good look...

*****

Anyway, this file, **README.md**, provides some general background for the project, while the **CodeBook.md** file contains a description of the final data set - with special attention given to its variables.  
The final data set will be obtained by running this project's main script, **run_analysis.R**. It will download the zipped data set (only if not present yet), unzip it, and then read and merge the data, dispersed over several files (and split in a *test* and *train* part). Finally, it will produce a second, independent tidy data set with the average of some variables (the mean() and avg() columns) grouped by activity and subject. This data set will be written to a csv-formatted file.  

*****

## How to "run" this project

1. Clone this repository (git clone https://github.com/jdoornaert/Getting-and-Cleaning-Data-Course-Project.git)
2. (optional) copy or download the zipped the data set into the local folder
3. Run the script (Rscript run_analysis.R)
4. The resulting dataset will be stored in the file *output.csv*

*****