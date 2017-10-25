%author: Nakkina Tapan Ganatma
tic;
%%
% clear;
% %NOTE: You will need my user created functions
% %called PSDs.m, snowmeup.m to run this...
%Declared all those patients data that we have to extract
patients=[1,2,3,4,5,6,7,8,9,10,11,14,15,18,19,20,21,22,23,24];%,12
%Number of files with respect to every patient
fileLength = [42,35,38,42,39,18,19,20,19,25,35,24,33,26,40,19,0,36,30,29,33,31,9,22];
%Number of Seizure files that are being selected for each patient for
%forming the training dataset
Seizure_number=[5,1,5,2,3,7,2,3,2,5,2,5,15,4,2,5,2,2,5,12];
%Number of Non-Seizure files selected accordingly to maintain 80%-20% ratio
%for generating the training and testing datasets
for g = 1:length(patients)
    Non_S_number(g) = round(fileLength(patients(g))*0.8)-Seizure_number(g);
end

%accessing the annotations.csv file where all the annotations are
%present
annotation = csvread('annotations.csv',1,0); %Loading the csv value that has the annotations of when seizures start and stop, skips the first line

%This loop is used to generate datsets for each specified patient
for y = 1:length(patients)
    %This will be the amnt of time before seizure we are paying attention to (in seconds)
    TimeBack = 0*60; 
    %snow.m function: (for snowbaall features)
    Hist = zeros(8,30);
    LastT = zeros(8,1);
    HistA1 = zeros(8,30);
    LastTA1 = zeros(8,1);
    HistA2 = zeros(8,30);
    LastTA2 = zeros(8,1);
    
    %Forming a matrix for the training dataset
    Train = [];
    %patient_num => number of the patient that is being accessed
    patient_num=patients(y);
    timeElapsed = 0;
    
    valTrain=[];
    AnnoNum = [];
    file = [];
    file_size = [];
    NON = [];
    File_Lengths = [];
    File_Lengths_sum = [];
    To_Read = [];
    anno = [];
    a=0;
    num_seizure = [];
    %channels that we consider for extracting datasets
    channel1=[];
    channel2=[];
    filedata=[];
    
    %file_size => Number of unique seizure files
    %num_seizure => Total Number of seizure files
    %AnnoNum => Gives the number where the Seizure files end in the
    %annotation.csv for the respective patient
    file_size = 0;
    num_seizure = 0;
    for k = 1:size(annotation,1)
        if annotation(k,1) == patient_num
            if (k~=1)
                if(annotation(k,2)~= annotation(k-1,2))
                    file_size = file_size+1;
                end
            else
                file_size = file_size+1;
            end
            num_seizure =  num_seizure+1;
            AnnoNum = k;
        end
    end
    %AnnoNum gives the starting index of the seizure files for the
    %respective patient
    AnnoNum = AnnoNum - (num_seizure-1);
    %NON gives the total number of non-seizure files for the patient
    NON = fileLength(patient_num)-num_seizure;
    
    AAAAA = zeros(length(patient_num),5); %Max of 5 Non-S files
    To_Read = zeros(length(patient_num),10); %Max of 10 files to be analyzed from each patient
    
    for i = 1:length(patient_num)
        %S_files is a zero array of dimensions 1X(Unique seizure files)
        S_files = zeros(length(patient_num),file_size); %edit%so that every row will have a zero in it
        %NON_files is a zero array of dimensions 1X(Unique non-seizure files)
        NON_files = zeros(length(patient_num),NON);
        Counter = 1;
        
        % listing gets the info of all files in the given directory
        listing=ls('C:\Program Files\Epilepsy-Data\');
        
        if patient_num(i)<10
            Type = strcat('chb','0',num2str(patient_num(i)));
        else
            Type = strcat('chb',num2str(patient_num(i)));
        end
        
        %listingF gets the info of all files in the given patient folder
        listingF = ls(strcat('C:\Program Files\Epilepsy-Data\',Type));
        
        %listing_file gets the info of all files in the given patient
        %folder without (. and ..)
        listing_file = listingF(3:end,:);
        
        S_files =[];
        %S_files gets the numbers of all Seizure files
        S_files(i,:) = annotation(annotation(:,1)==patient_num,2);
        %NON_files gives the numbers of all non-seizure files
        NON_files(i,:) = [setdiff(1:size(listing_file,1),unique(S_files(i,:)))];
               
        %fprintf('With a maximum of %d Seizure files for patient %d.\n',num_seizure(i),patient_num(i));%file_size(i)
        %Seizure gets the number of seizure files that are considered for
        %forming the training dataset
        Seizure = Seizure_number(y);%input('How many Seizure files would you like to analyze?\n');
        %fprintf('\nWith a maximum of %d NON-Seizure files for patient %d.\n',NON(i),patient_num(i));
        %Non_S gets the number of non-seizure files considered for forming training dataset 
        Non_S = Non_S_number(y);%input('How many NON Seizure files would you like to analyze?\n');
        
        %Randomly selects the seizure and non-seizure files from the
        %database to form training datasets.  (Sfiles and AAAAA)
        AAAAA = sort(datasample(NON_files(i,1:NON(i)),Non_S,'Replace',false));
        Sfiles = sort(datasample(S_files(i,1:num_seizure(i)),Seizure,'Replace',false));%file_size(i)
        %checks whether unique fies being selcted or not
        while length(unique(AAAAA)) ~= length(AAAAA) %(i,1:Non_S)
            AAAAA = sort(datasample(NON_files(i,:),Non_S));
        end
        while length(unique(Sfiles)) ~= length(Sfiles) || all(Sfiles) == 0
            Sfiles = datasample(S_files(i,:),Seizure);
        end
        
        %To_Read combines the seizure and non-seizure indexes
        To_Read(i,1:length(Sfiles)+length(AAAAA)) =  [Sfiles AAAAA];
        %Reads is the sorted version of To_Read
        Reads = [];
        Reads = sort(To_Read(i,1:length(Sfiles)+length(AAAAA)));
        
        if patient_num(i)<10 %if the patient number is less than 10 we need to format it
            patient_file=1:fileLength(patient_num(i));
            num = num2str(patient_num(i));
            pathname = strcat('C:\Program Files\Epilepsy-Data\','chb0',num); %Change to where the files are stored
            cd(pathname);
            for p = 1:length(Reads)
                %changes number of channels according to the patient number
                if patients(y)==11 && Reads(p)==1
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)<11
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)==11 && Reads(p)~=1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && Reads(p)<11
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && Reads(p)>10 && Reads(p)<14
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==12 && Reads(p)>13
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==14
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && Reads(p)==1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && Reads(p)>1
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==18 && Reads(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==18 && Reads(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==19 && Reads(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==19 && Reads(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>19 && patients(p)<23
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>22
                    no_channel1 = 20;
                    no_channel2 = 16;
                end
                %reads and forms the initial raw training dataset (valTrain)
                record_file = listing_file(Reads(p),:);
                X{p} = record_file; %{} means load it as a string, and only specific file p, and store into array X
                file=load(X{p}); %loads it as a structure
                filedata = file.record([no_channel1 no_channel2],:);
                valTrain=[valTrain,filedata]; %creates an array in valTrain, and stacks on at the end of the array
                File_Lengths = [File_Lengths, size(file.record,2)/256];  
            end
        else %repeat if patient_num is greater than 9 (does not start with '0')
            patient_file=1:fileLength(patient_num(i));
            num = num2str(patient_num(i));
            pathname = strcat('C:\Program Files\Epilepsy-Data\','chb',num);
            cd(pathname);
            for p = 1:length(Reads)
                if patients(y)==11 && Reads(p)==1 % takes care of change in channels between files in a patient folder
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)<11
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)==11 && Reads(p)~=1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && Reads(p)<11
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && Reads(p)>10 && Reads(p)<14
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==12 && Reads(p)>13
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==14
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && Reads(p)==1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && Reads(p)>1
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==18 && Reads(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==18 && Reads(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==19 && Reads(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==19 && Reads(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>19 && patients(p)<23
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>22
                    no_channel1 = 20;
                    no_channel2 = 16;
                end
                record_file = listing_file(Reads(p),:);
                X{p} = record_file; %{} signifies to load it as a string, and only specific file p, and store into array X
                file=load(X{p}); %loads it as a structure
                filedata = file.record([no_channel1 no_channel2],:);
                valTrain=[valTrain,filedata]; %creates an array in valTrain, and stacks on at the end of the array
                File_Lengths = [File_Lengths, size(file.record,2)/256];         
            end
        end
        for u = 1:length(Reads)
            if u==1
                File_Lengths_sum(u)=File_Lengths(u);
            else
                File_Lengths_sum(u)=File_Lengths_sum(u-1)+File_Lengths(u);
            end
        end
        record = valTrain;
        [r,c] = size(record);
        if i>1
            c=c-File_Lengths(a)*256;
        end
        %----------------------------------------------------------------------
        %Create Annotations
        %c is total data points from all the files, anno is total length of all files in seconds
        anno = [anno zeros(1,c/256)];
        
        Random = 0;
        Other = 0;
        Random_S = 0;
        Other_S = 0;
        Real =1;  
        cd('C:\Users\chand_000\Documents\Cerebro')
        Ref = importdata('Seizure Reference Chart.txt', '\t');
        cd(pathname)
        for k = 1:length(Reads)
            if k==length(Reads)&& Reads(k)~=AAAAA(end)
                if patient_num(i)<10
                    if Reads(k)<10
                        IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_0',num2str(Reads(k))));
                    else
                        IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_',num2str(Reads(k))));
                    end
                else
                    if Reads(k)<10
                        IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_0',num2str(Reads(k))));
                    else
                        IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_',num2str(Reads(k))));
                    end
                end
                Index = find(not(cellfun('isempty', IndexC)));
                SeizureStart = Ref.data(Index,1);
                SeizureEnd = Ref.data(Index,2);
                NumSeizures = length(SeizureStart);
                aa=0;
                while aa<NumSeizures
                    aa=aa+1;
                    tseizurestart = SeizureStart(aa);
                    tseizureend = SeizureEnd(aa);
                    if k==1
                        if tseizurestart - TimeBack < 0
                            anno(1:tseizureend)=1;
                        else
                            anno((tseizurestart-TimeBack):(tseizureend))=1;
                        end
                    else
                        if tseizurestart - TimeBack < 0
                            anno(File_Lengths_sum(k-1)+1:File_Lengths_sum(k-1)+tseizureend)=1;
                        else
                            anno(File_Lengths_sum(k-1)+tseizurestart-TimeBack:File_Lengths_sum(k-1)+tseizureend)=1;
                        end
                    end
                end
                
            elseif Reads(k)==AAAAA(Real)
                if k==1
                    anno(1:File_Lengths_sum(k))=0;
                else
                    anno(File_Lengths_sum(k-1)+1:File_Lengths_sum(k))=0;
                end
                Real=Real+1;
            else
                if patient_num(i)<10
                    if Reads(k)<10
                        IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_0',num2str(Reads(k))));
                    else
                        IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_',num2str(Reads(k))));
                    end
                else
                    if Reads(k)<10
                        IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_0',num2str(Reads(k))));
                    else
                        IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_',num2str(Reads(k))));
                    end
                end
                Index = find(not(cellfun('isempty', IndexC)));
                SeizureStart = Ref.data(Index,1);
                SeizureEnd = Ref.data(Index,2);
                NumSeizures = length(SeizureStart);
                aa=0;
                while aa<NumSeizures
                    aa=aa+1;
                    tseizurestart = SeizureStart(aa);
                    tseizureend = SeizureEnd(aa);
                    if k==1
                        if tseizurestart - TimeBack < 0
                            anno(1:tseizureend)=1;
                        else
                            anno((tseizurestart-TimeBack):(tseizureend))=1;
                        end
                    else
                        if tseizurestart - TimeBack < 0
                            anno(File_Lengths_sum(k-1)+1:File_Lengths_sum(k-1)+tseizureend)=1;
                        else
                            anno(File_Lengths_sum(k-1)+tseizurestart-TimeBack:File_Lengths_sum(k-1)+tseizureend)=1;
                        end
                    end
                end
            end
        end
        
        
    end
   
    %Extracting the RP Features
    
    cd('C:\Users\chand_000\Documents\Cerebro') %Change to where the files are stored
    [PSD] = PSDs(1, record);
    Feature1 = PSD; %Feature to compare
    
    [PSD] = PSDs(2, record);
    Feature2 = PSD; %Feature to compare
      
    signal1 = Feature1(:,:); %SeizureStart-15*60:SeizureEnd
    signal2 = Feature2(:,:);
    
    h1 = hilbert(signal1'); %hilbert transform
    h2 = hilbert(signal2');
    
    [phase1] = unwrap(angle(h1));
    [phase2] = unwrap(angle(h2));
    
    phase1 = phase1';
    phase2 = phase2';
    %Hilbert requires over integration over infinite time, therefore
    % 10% of the instantaneous values get discarded on each side of the window
    origlength = length(phase1);
    phase1start = floor(length(phase1)*.1);
    phase1end = length(phase1) - floor(length(phase1)*.1);
    phase1 = phase1(:,phase1start:phase1end);
    phase2 = phase2(:,phase1start:phase1end);
    
    A1 = phase1;
    [snowball, Hist, LastT] = snowmeup(A1,HistA1,LastTA1);
    snowphase = snowball;
    %Assume EEG is obtained from same physiological system, therefore they
    %should be equal
    n=1;
    m=1;
    RP = n*phase1 - m*phase2; %relative phase
    P_L_V = abs(sum(exp(i*RP)/length(RP))); %Phase Locking Value
    
    
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %PART 3: Extract the Snowball Features
    %Given that we have Feature1 already (PSD), we just need to "snowball"
    %it now:
    [snowball, Hist, LastT] = snowmeup(Feature1,Hist,LastT);
    
    %Part 4: Create Training Data:
    Train = [Train, [anno(phase1start:phase1end);snowball(:,phase1start:phase1end);snowphase;RP]];
    Train=Train';
    %Train=[Train,Feature3(phase1start:phase1end,:)];
    toc; %tells us how long a run takes
    cd('H:\Ganatma\seizure\training data-2min');
    if patients(y)<10
        filename1 = strcat('training-chb0',num2str(patients(y)),'.xlsx');
    else
        filename1 = strcat('training-chb',num2str(patients(y)),'.xlsx');
    end
    xlswrite(filename1,Train);
    beep
    cd('H:\Ganatma\seizure');
    tic; %Start time of processing data
    % %PART 0: USER INPUTS:
    % disp('PART 0: LOAD RAW DATA AND ANNOTATION')
    
    if patients(y)~=14 && patients(y)~=21
        no_channel1 = 20;%20;%T7-FT9 is 25 for chb14%input('Enter first channel number we want: '); %Just enter the number here
        no_channel2 = 16;%16;%P8-O2 is 22 for chb14%input('Enter second channel number we want: '); %Just enter the number here
    else
        no_channel1 = 25;
        no_channel2 = 22;
    end
    % %For snow.m function:
    Hist = zeros(8,30);
    LastT = zeros(8,1);
    %
    HistA1 = zeros(8,30);
    LastTA1 = zeros(8,1);
    
    %For Running in RandomForest Treebagger:
    Test = [];
    %%
    %This section onwards code for testing dataset to be formed
    patient_num=patients(y);
    i = 1;
    
    fileLength = [42,35,38,42,39,18,19,20,19,25,35, 24,33,26,40,19,0,36,30,29,33,31,9,22]; %The corresponding number of files in each patient
    
    timeElapsed = 0;
    
    annotation = csvread('annotations.csv',1,0); %Loading the csv value that has the annotations of when seizures start and stop
    
    valTest=[];
    File_Lengths1 = [];
    
    %fprintf('After Training %d seizure file(s) of max %d.\n',Seizure,num_seizure(i))%file_size
    Seizure1 = num_seizure(i)-Seizure_number(y); %input('How many Seizure files would you like to analyze?\n');
    
    %fprintf('\nAfter Training %d NON-seizure file(s) of max %d.\n',Non_S,NON(i))
    Non_S1 = NON(i)-Non_S_number(y);%input('How many NON Seizure files would you like to analyze?\n');
    
    AAAAA1 = sort(datasample(NON_files,Non_S1));
    Sfiles1 = sort(datasample(S_files,Seizure1));
    
    if Seizure1+Seizure <= file_size
        B1 = [AAAAA(1:end-1) AAAAA1 Sfiles1 Sfiles];
    else
        B1 = [AAAAA(1:end-1) AAAAA1 Sfiles1]; %CHANGE HERE if you want to categorize specific seizure file repeats
    end
    
    while length(unique(B1)) ~= length(B1)
        AAAAA1 = sort(datasample(NON_files,Non_S1));
        Sfiles1 = sort(datasample(S_files,Seizure1));
        if Seizure1+Seizure <= file_size
            B1 = [AAAAA(1:end-1) AAAAA1 Sfiles1 Sfiles];
        else
            B1 = [AAAAA(1:end-1) AAAAA1 Sfiles1];
        end
    end
    To_Read1 = sort([AAAAA1 Sfiles1]);
    
    
    for q = 1:size(patient_num,2) %This For-Loop will allow us to cycle through our patients
        if patient_num(i)<10 %if the patient number is less then 10 we need to format it
            patient_file=1:fileLength(patient_num(i));
            num = num2str(patient_num(i));
            pathname = strcat('H:\Ganatma\Epilepsy-Data\','chb0',num);
            cd(pathname);
            for p = 1:length(To_Read1)
                if patients(y)==11 && To_Read1(p)==1
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)<11
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)==11 && To_Read1(p)~=1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && To_Read1(p)<11
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && To_Read1(p)>10 && To_Read1(p)<14
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==12 && To_Read1(p)>13
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==14
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && To_Read1(p)==1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && To_Read1(p)>1
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==18 && To_Read1(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==18 && To_Read1(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==19 && To_Read1(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==19 && To_Read1(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>19 && patients(p)<23
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>22
                    no_channel1 = 20;
                    no_channel2 = 16;
                end
                record_file = listing_file(To_Read1(p),:);
                X{p} = record_file; %{} means load it as a string, and only specific file p, and store into array X
                file=load(X{p}); %loads it as a structure
                channel1=file.record(no_channel1,:);
                channel2=file.record(no_channel2,:);
                filedata(1,:)=channel1;
                filedata(2,:)=channel2;
                valTrain=[valTrain,filedata]; %creates an array in valTrain, and stacks on at the end of the array
                File_Lengths = [File_Lengths, size(file.record,2)/256];
            end
        else %repeat if patient_num is greater than 9 (does not start with '0')
            patient_file=1:fileLength(patient_num(i));
            num = num2str(patient_num(i));
            pathname = strcat('H:\Ganatma\Epilepsy-Data\','chb',num);
            cd(pathname);
            for p = 1:length(To_Read1)
                if patients(y)==11 && To_Read1(p)==1
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)<11
                    no_channel1 = 20;
                    no_channel2 = 16;
                elseif patients(y)==11 && To_Read1(p)~=1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && To_Read1(p)<11
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==12 && To_Read1(p)>10 && To_Read1(p)<14
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==12 && To_Read1(p)>13
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==14
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && To_Read1(p)==1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==15 && To_Read1(p)>1
                    no_channel1 = 26;
                    no_channel2 = 23;
                elseif patients(y)==18 && To_Read1(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==18 && To_Read1(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)==19 && To_Read1(p)==1
                    no_channel1 = 3;
                    no_channel2 = 22;
                elseif patients(y)==19 && To_Read1(p)>1
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>19 && patients(p)<23
                    no_channel1 = 25;
                    no_channel2 = 22;
                elseif patients(y)>22
                    no_channel1 = 20;
                    no_channel2 = 16;
                end
                record_file = listing_file(To_Read1(p),:);
                X{p} = record_file; %{} means load it as a string, and only specific file p, and store into array X
                file=load(X{p}); %loads it as a structure
                channel1=file.record(no_channel1,:);
                channel2=file.record(no_channel2,:);
                filedata(1,:)=channel1;
                filedata(2,:)=channel2;
                valTrain=[valTrain,filedata]; %creates an array in valTrain, and stacks on at the end of the array
                File_Lengths = [File_Lengths, size(file.record,2)/256];
            end
        end
        %     i = i+1;
    end
    for u = 1:length(To_Read1)
        if u==1
            File_Lengths1_sum(u)=File_Lengths1(u);
        else
            File_Lengths1_sum(u)=File_Lengths1_sum(u-1)+File_Lengths1(u);
        end
    end
    record = valTest;
    [r,c] = size(record);
    
    %Creating Annotations
    anno = zeros(1,c/256);
    
    Random = 0;
    Other = 0;
    Random_S = 0;
    Other_S = 0;
    Real = 1;
    Ref = importdata('H:\Ganatma\seizure\Seizure Reference Chart.txt', '\t');
    
    for k = 1:length(To_Read1)
        if k==length(To_Read1)&& To_Read1(k)~=AAAAA1(end)
            if patient_num(i)<10
                if To_Read1(k)<10
                    IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_0',num2str(To_Read1(k))));
                else
                    IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_',num2str(To_Read1(k))));
                end
            else
                if To_Read1(k)<10
                    IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_0',num2str(To_Read1(k))));
                else
                    IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_',num2str(To_Read1(k))));
                end
            end
            Index = find(not(cellfun('isempty', IndexC)));
            SeizureStart = Ref.data(Index,1);
            SeizureEnd = Ref.data(Index,2);
            NumSeizures = length(SeizureStart);
            aa=0;
            while aa<NumSeizures
                aa=aa+1;
                tseizurestart = SeizureStart(aa);
                tseizureend = SeizureEnd(aa);
                if k==1
                    if tseizurestart - TimeBack < 0
                        anno(1:tseizureend)=1;
                    else
                        anno((tseizurestart-TimeBack):(tseizureend))=1;
                    end
                else
                    if tseizurestart - TimeBack < 0
                        anno(File_Lengths1_sum(k-1)+1:File_Lengths1_sum(k-1)+tseizureend)=1;
                    else
                        anno(File_Lengths1_sum(k-1)+tseizurestart-TimeBack:File_Lengths1_sum(k-1)+tseizureend)=1;
                    end
                end
            end
            
        elseif To_Read1(k)==AAAAA1(Real)
            if k==1
                anno(1:File_Lengths1_sum(k))=0;
            else
                anno(File_Lengths1_sum(k-1)+1:File_Lengths1_sum(k))=0;
            end
            Real=Real+1;
        else
            if patient_num(i)<10
                if To_Read1(k)<10
                    IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_0',num2str(To_Read1(k))));
                else
                    IndexC = strfind(Ref.textdata, strcat('chb0',num2str(patient_num(i)),'_',num2str(To_Read1(k))));
                end
            else
                if To_Read1(k)<10
                    IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_0',num2str(To_Read1(k))));
                else
                    IndexC = strfind(Ref.textdata, strcat('chb',num2str(patient_num(i)),'_',num2str(To_Read1(k))));
                end
            end
            Index = find(not(cellfun('isempty', IndexC)));
            SeizureStart = Ref.data(Index,1);
            SeizureEnd = Ref.data(Index,2);
            NumSeizures = length(SeizureStart);
            aa=0;
            while aa<NumSeizures
                aa=aa+1;
                tseizurestart = SeizureStart(aa);
                tseizureend = SeizureEnd(aa);
                if k==1
                    if tseizurestart - TimeBack < 0
                        anno(1:tseizureend)=1;
                    else
                        anno((tseizurestart-TimeBack):(tseizureend))=1;
                    end
                else
                    if tseizurestart - TimeBack < 0
                        anno(File_Lengths1_sum(k-1)+1:File_Lengths1_sum(k-1)+tseizureend)=1;
                    else
                        anno(File_Lengths1_sum(k-1)+tseizurestart-TimeBack:File_Lengths1_sum(k-1)+tseizureend)=1;
                    end
                end
            end
        end
    end
    
    %PART 2: Extract the RP Features
    cd('H:\Ganatma\seizure')
    [PSD] = PSDs(no_channel1, record);
    Feature1 = PSD; %Feature to compare
    
    [PSD] = PSDs(no_channel2, record);
    Feature2 = PSD; %Feature to compare
    
    % [freqfeatures_var] = freqfeatures(no_channel1, record);
    % Feature3 = freqfeatures_var; %Feature to compare
    
    signal1 = Feature1(:,:); %SeizureStart-15*60:SeizureEnd
    signal2 = Feature2(:,:);
    
    h1 = hilbert(signal1');
    h2 = hilbert(signal2');
    
    [phase1] = unwrap(angle(h1));
    [phase2] = unwrap(angle(h2));
    
    phase1 = phase1';
    phase2 = phase2';
    %Hilbert requires over integration over infinite time, therefore
    % 10% of the instantaneous values get discarded on each side of the window
    origlength = length(phase1);
    phase1start = floor(length(phase1)*.1);
    phase1end = length(phase1) - floor(length(phase1)*.1);
    phase1 = phase1(:,phase1start:phase1end);
    phase2 = phase2(:,phase1start:phase1end);
    
    A1 = phase1;
    [snowball, Hist, LastT] = snowmeup(A1,HistA1,LastTA1);
    snowphase = snowball;
    %Assume EEG is obtained from same physiological system, therefore they
    %should be equal
    n=1;
    m=1;
    RP = n*phase1 - m*phase2; %relative phase
    P_L_V = abs(sum(exp(i*RP)/length(RP))); %Phase Locking Value
    
    %PART 3: Extract the Snowball Features
    %Given that we have Feature1 already (PSD), we just need to "snowball"
    %it now:
    [snowball, Hist, LastT] = snowmeup(Feature1,Hist,LastT);
    
    %Part 4: Create Training Data:
    Test = [Test, [anno(phase1start:phase1end);snowball(:,phase1start:phase1end);snowphase;RP]];
    Test=Test';
    %Test=[Test,Feature3(phase1start:phase1end,:)];
    toc; %tells us how long a run takes
    cd('H:\Ganatma\seizure\testing data-2min');
    if patients(y)<10
        filename1 = strcat('testing-chb0',num2str(patients(y)),'.xlsx');
    else
        filename1 = strcat('testing-chb',num2str(patients(y)),'.xlsx');
    end
    xlswrite(filename1,Test);
    beep
    cd('H:\Ganatma\seizure');
    
    beep
end