Codebook and Study Design - run_analysis.R

Data / Study Design
-------------------

Raw data:
---------

activity_labels.txt 	- numeric ids to corresponding exercises

features.txt 			- Entire list of values that were measured per (!) exercise

subject_test.txt	- Each row represents an id of the test subject
X_train.txt 		- Row corresponds to a subject's id, and each column is a 
					  measurement of each of the features in features.txt
y_train.txt 		- Each row contains the 

subject_train.txt	- Each row contains a numeric id of the test subject
X_test.txt 			- Row corresponds to a subject's id, and each column is a 
					  measurement of each of the features in features.txt
y_train.txt 		- One column containing a numeric id of the exercise


libraries used:
---------------
data.table
dplyr
plyr


Variables
---------

*All variables were populated directly from files noted above under raw data.

Information regarding the 'features' data that was collected from all the subjects:

""
The features selected for this database come from the accelerometer and gyroscope 3-axial 
raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time)
were captured at a constant rate of 50 Hz. Then they were filtered using a median filter 
and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove 
noise. Similarly, the acceleration signal was then separated into body and gravity 
acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass 
Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to 
obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these 
three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, 
tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing 
fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, 
fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

""

features			- data.table with 'id' and 'features' column, denoting the exact variable names that were collected.
extractString		- "mean|std" for use with grep matching to extract wanted columns from "features" variable

labels				- data.frame short list of the actual exercise character string corresponding with an id # of that exercise.
					  
					  Exercises are given as: 
					  1 WALKING
					  2 WALKING_UPSTAIRS
					  3 WALKING_DOWNSTAIRS
					  4 SITTING
					  5 STANDING
					  6 LAYING


dt_test_subjects	- data.frame of test subject id #s, with "subject_id" as the column name
dt_test_set			- data.frame of features/data set that were collected from phones. Measured units are in gravity (g)!
dt_test_exercises	- data.table of a column with exercises listed as factors.

dt_train_subjects	- data.frame of test subject id #s, with "subject_id" as the column name
dt_train_set		- data.frame of features/data set that were collected from phones. 
dt_train_exercises	- data.table of a column with exercises listed as factors.

The number of total different subjects should be 30, since there were 30 different, unique observations

dt*set				- variables are measured in gravity, normalized [-1, 1], unit vectors

All dt* variables above have a column id # corresponding to the number of their respective observations.
This is column is stirctly used as a key to merge and nothing else. 

dt_train_data		- columns: <row id #> <subject id #> <exercise> <..feature/data set..>
dt_test_data		- columns: <row id #> <subject id #> <exercise> <..feature/data set..>
prelim_data 		- rbind() both dt_train_data and dt_test_data, just 'appended' both as they are mutually exclusive
					  but contain the same kind of data.
					  The column of id #s used as a key has been dropped.

tidy_data			- cleaned up list consisting of subject id numbers, and collapsed, mean values for each of the measured data for each
					  exercise.


					  
Transformations
---------------

Listed outline format below also follows steps in the code.

1. Read and process all data into respective variables as noted above.

	A. Exercise labels ("labels") were read in, and the column id #'s removed, since they are already 
	   in an order that corresponds to their list placement index.
	   
	B. dt_test_subjects and dt_train_subjects are given the column name "subject_id" to better clarify what we're looking at.
	
	B. Only dt_test_exercises and dt_train_exercises were read in as tables (vs. frame). This is so I can
	   easily replace the exercise #s with the actual names of the exercises. Then the column was converted
	   to factors for group_by to work correctly. Then finally converted them to data.frames so it can be 
	   joined at the end with all the other data frames.
	
	C. dt_train_set and dt_test_set were read in and the columns were immediately named according
	   to the features list given. Then they were culled using grep and "extractString" for just to get the 
	   std and mean measurements/columns only.
	   
	D. A column of unique id#s were added to each of the dt*set, dt*subjects, dt*exercises so that we can
	   use that as a key to merge them. The # of unique ids corresponds to the total rows found in the 
	   respective train or test set of data.
	E. The columns in dt*exercises variables were converted to factors, as this allowed group_by to 
	   properly group them during the last tidy data step. It wouldn't group them otherwise.

	   
2.  Combine the data
 
 A. Used "join_all" to join all the test and train information:
	   1. dt_train_data and dt_test_data is now a data frame consisting of:
  	      <test subject id> <exercises> <measurement data>

    B. The key column that was used to merge the data frames is removed to form semi-tidy data, since it's
	   not needed.

    C. Used rbind to simply append the train and test data frames together for the master, semi-raw dat.
	

3. Provide tidy data

   A. What we want to do, is to collapse the list of exercises to just 6 per subject id so we can summarize them. 
      This can be done using group_by(subject_id, exercise). It will leave 6 identical subject_ids per subject, since each 
	  subject did 6 different exercises. 

   B. We then pass this modified data frame to summarize_each(funs(mean)) to take the mean of each exercise, which
      then results in the expected table.
	  
	  
Processed / Tidy Data:
   - Table with just the mean of any of the mean() and std() of measurements, for each (6) activity 
     (STANDING, WALKING, .. etc) per person/subject (30). Resultant table will have 180 rows.


      
	