Scripts and functions used:

run_analysis.R > function run_analysis()

arguments 	: none
outputs 	: tidy_data.txt

The purpose of run_analysis() is to parse through 30 different people subjected to 6 
exercise tortures such as WALKING, RUNNING, etc, and their resulting various measured 
values coming from their phone accelerometers 

The result of run_analysis() is to output a collapsed mean/avg of the mean() and std()
columns of the 6 exercises they performed for each person.