# cerebro
Texas A&amp;M ENGR 491 Seizure Prediction Algorithm 

To Obtain the Training Data
1. Change line 30 of AllRPandSnowballExtraction1.m to the appropriate patient(s)
2. Personalize lines 62, 70, 110, 167 to where the patient files are stored
3. Personalize lines 296 and 394 to where the AllRPandSnowballExtracction1.m is stored
4. Personalize line 388 to where the Excel file should be stored that will run for balancing on ps.R
5. When running the program, the program will prompt user input for the number of seizure and non-seizure files you want

To Obtain the Testing Data
1. Change line 26 of testingData1.m to the appropriate patient(s)
2. Personalize lines 58, 66, 113, 170 to where the patient files are stored
3. Personalize lines 321 and 391 to where the patiet files are stored
4. Personalize line 383 to where the Excel file should be stored that will run for balancing on ps.R
5. When running the program, the program will prompt the user input for the number of seiuzre and  non-seizure files you want

After Balancing on randomforest.m
1. Personalize line 16 to where the Excel files are stored
2. Personalize line 19 to where the code is stored

Without Balancing on randomforest.m
1. Comment out lines 16-19

Balancing with ps.R
1. Personalize line 9 to where the Excel files from MATLAB are stored
2. Run the program with randomforest in it thru ps.R
