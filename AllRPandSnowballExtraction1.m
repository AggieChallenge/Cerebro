 tic;
clc
clear
%%
% clear;
% %NOTE: You will need my user created functions
% %called PSDs.m, snowmeup.m to run this...
% Start time of processing data
% %PART 0: USER INPUTS:
% disp('PART 0: LOAD RAW DATA AND ANNOTATION')

%no_channel1 = 20;%T7-FT9%input('Enter first channel number we want: '); %Just enter the number here
%no_channel2 = 16;%P8-O2%input('Enter second channel number we want: '); %Just enter the number here
TimeBack = 0*60; %This will be the amnt of time before seizure we are paying attention to (in seconds)
%
% %For snow.m function:
Hist = zeros(8,30);
LastT = zeros(8,1);
%
HistA1 = zeros(8,30);
LastTA1 = zeros(8,1);
%
% %For Running in RandomForest Treebagger:
Train = [];
%
% %This section will allow us to load the file using these numeric
% %vectors by converting them into strings
% %figure

patient_num=[1]; %NOT Ch 17


fileLength = [42,35,38,42,39,18,19,20,19,25,35,24,33,26,40,19,0,36,30,29,33,31,9,22]; %The corresponding number of files in each patient

timeElapsed = 0;

annotation = csvread('annotations.csv',1,0); %Loading the csv value that has the annotations of when seizures start and stop, skips the first line

valTrain=[];
AnnoNum = {};
file = [];
file_size = {};
NON = {};
File_Lengths = [];
anno = [];
a=0;
    
for iii = 1:length(patient_num)
    file_size{1,patient_num(iii)} = length(annotation(annotation(:,1)==patient_num(iii),2)); % length of all seizure events
    file_size{2,patient_num(iii)} = length(unique(annotation(annotation(:,1)==patient_num(iii),2))); %# of seizure files
    file_size{3,patient_num(iii)} = unique(annotation(annotation(:,1)==patient_num(iii),2)); %# of seizure files
    AnnoNum{patient_num(iii)} = find(annotation(:,1) == patient_num(iii),1);
    NON{patient_num(iii)} = fileLength(patient_num(iii))-file_size{2,patient_num(iii)};
end

S_files = cell([1,length(fileLength)]);
NON_files = {};
for i = 1:length(patient_num)
    [Sig,MAX] = mode(annotation(AnnoNum{patient_num(i)}:AnnoNum{patient_num(i)}+file_size{1,patient_num(i)}-1,2));
    num = num2str(patient_num(i));
    X = {};  
    listing=ls('C:\Program Files\Epilepsy-Data\');
    
    if patient_num(i)<10
        Type = strcat('chb','0',num);
    else
        Type = strcat('chb',num);
    end
    
    listing_file = ls(strcat('C:\Program Files\Epilepsy-Data\',Type));
    listing_file = listing_file(3:end,:);
    ALL = {}; % USE CELLSTR - CHANGE!
    for t = 1:size(listing_file,1)
        ALL{t,i} = listing_file(t,:);
    end
    
    fprintf('With a maximum of %d Seizure files for patient %d.\n',file_size{2,patient_num(i)},patient_num(i));
    NumS = 4;%input('How many Seizure files would you like to analyze?\n');
    
    fprintf('\nWith a maximum of %d NON-Seizure files for patient %d.\n',NON{patient_num(i)},patient_num(i));
    Non_S = 1;%input('How many NON Seizure files would you like to analyze?\n');
    TempS = {};
    for h = 1:file_size{2,patient_num(i)}
        if file_size{3,patient_num(i)}(h)<10
            TempS{h} = [listing_file(1,1:6), num2str(0), num2str(file_size{3,patient_num(i)}(h)), listing_file(1,9:end)];
        else
            TempS{h} = [listing_file(1,1:6), num2str(file_size{3,patient_num(i)}(h)), listing_file(1,9:end)];
        end
    end
    TempS = unique(TempS);
    S_files{patient_num(i)} = TempS';
    NON_files{patient_num(i)} = erase(ALL(:,i),S_files{patient_num(i)});
    NON_files{patient_num(i)}(all(cellfun('isempty',NON_files{patient_num(i)}),2),:) = [];
    Select_NON = [];
    Select_S = [];
    while size(unique(Select_NON),1) + size(unique(Select_S),1) ~= NumS+Non_S
        if Non_S ~= 0
            Select_NON = datasample(NON_files{patient_num(i)},Non_S);
            Select_NON = sort(Select_NON);
        end
        if NumS ~= 0
            Select_S = datasample(S_files{patient_num(i)},NumS);
            Select_S = sort(Select_S);
        end
    end
    True = [Select_NON; Select_S];
    True = sort(True);
    if patient_num(i)<10 %if the patient number is less than 10 we need to format it
        patient_file=1:fileLength(patient_num(i));
        pathname = strcat('C:\Program Files\Epilepsy-Data\','chb0',num); %Change to where the files are stored
        cd(pathname);
        for p = 1:length(True)
            if patient_num(i)==11 && str2double(True{p}(7:8)) == 1
                no_channel1 = 20;
                no_channel2 = 16;
            elseif patient_num(i)<11
                no_channel1 = 20;
                no_channel2 = 16;
            elseif patient_num(i)==11 && str2double(True{p}(7:8))~=1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==12 && str2double(True{p}(7:8))<11
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==12 && str2double(True{p}(7:8))>10 && str2double(True{p}(7:8))<14
                no_channel1 = 26;
                no_channel2 = 23;
            elseif patient_num(i)==12 && str2double(True{p}(7:8))>13
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==14
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==15 && str2double(True{p}(7:8))==1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==15 && str2double(True{p}(7:8))>1
                no_channel1 = 26;
                no_channel2 = 23;
            elseif patient_num(i)==18 && str2double(True{p}(7:8))==1
                no_channel1 = 3;
                no_channel2 = 22;
            elseif patient_num(i)==18 && str2double(True{p}(7:8))>1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==19 && str2double(True{p}(7:8))==1
                no_channel1 = 3;
                no_channel2 = 22;
            elseif patient_num(i)==19 && str2double(True{p}(7:8))>1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)>19 && patient_num(i)<23
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)>22
                no_channel1 = 20;
                no_channel2 = 16;
            end
            record_file = True{p}
            X{p} = record_file; %{} means load it as a string, and only specific file p, and store into array X
            file=load(X{p}); %loads it as a structure
            valTrain=[valTrain,file.record([no_channel1 no_channel2],:)]; %creates an array in valTrain, and stacks on at the end of the array
            File_Lengths = [File_Lengths, size(file.record([no_channel1 no_channel2],:),2)/256];
        end
    else %repeat if patient_num is greater than 9 (does not start with '0')
        patient_file=1:fileLength(patient_num(i));
        pathname = strcat('C:\Program Files\Epilepsy-Data\','chb',num); %Change to where the files are stored
        cd(pathname);
        for p = 1:length(True)
            if patient_num(i)==11 && str2double(True{p}(7:8)) == 1
                no_channel1 = 20;
                no_channel2 = 16;
            elseif patient_num(i)<11
                no_channel1 = 20;
                no_channel2 = 16;
            elseif patient_num(i)==11 && str2double(True{p}(7:8))~=1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==12 && str2double(True{p}(7:8))<11
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==12 && str2double(True{p}(7:8))>10 && str2double(True{p}(7:8))<14
                no_channel1 = 26;
                no_channel2 = 23;
            elseif patient_num(i)==12 && str2double(True{p}(7:8))>13
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==14
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==15 && str2double(True{p}(7:8))==1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==15 && str2double(True{p}(7:8))>1
                no_channel1 = 26;
                no_channel2 = 23;
            elseif patient_num(i)==18 && str2double(True{p}(7:8))==1
                no_channel1 = 3;
                no_channel2 = 22;
            elseif patient_num(i)==18 && str2double(True{p}(7:8))>1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)==19 && str2double(True{p}(7:8))==1
                no_channel1 = 3;
                no_channel2 = 22;
            elseif patient_num(i)==19 && str2double(True{p}(7:8))>1
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)>19 && patient_num(i)<23
                no_channel1 = 25;
                no_channel2 = 22;
            elseif patient_num(i)>22
                no_channel1 = 20;
                no_channel2 = 16;
            end
            record_file = True{p}
            X{p} = record_file; %{} means load it as a string, and only specific file p, and store into array X
            file=load(X{p}); %loads it as a structure
            valTrain=[valTrain,file.record([no_channel1 no_channel2],:)]; %creates an array in valTrain, and stacks on at the end of the array
            File_Lengths = [File_Lengths, size(file.record([no_channel1 no_channel2],:),2)/256];
        end
    end
    record = valTrain;
    [r,c] = size(record);
    if i>1 % so that anno does not get replaced with each new patient
        c=c-File_Lengths(a)*256;
    end
    %----------------------------------------------------------------------
    %%PART 1: Create Annotation
    %c is total data points from all the files, anno is total length of all files in seconds
    anno = [anno zeros(1,c/256)];
    
    Random = 0;
    Other = 0;
    Random_S = 0;
    Other_S = 0;
    Real =1;
    Seiz = 1;
    Select_NON{end+1} = '0';
    Numbers = zeros(1,size(Select_S,1));
    for s=1:size(Select_S,1)
        Numbers(s) = str2double(Select_S{s}(7:8));
    end
    Multiple = 0;     
    for j = 1:length(True)
        if j+a>1
            File_Lengths(j+a) = File_Lengths(j+a) + File_Lengths(j-1+a);
        end
        if True{j} == Select_NON{Real} %Non-seizure files
            for jj = 1:30
                if j+a==1
                    Random = randi([0+5 File_Lengths(j+a)-5],1,1);
                    anno(Random:Random+5) = 0;
                else
                    Other = randi([File_Lengths(j-1+a)+5 File_Lengths(j+a)-5],1,1);
                    anno(Other:Other+5) = 0;
                end
            end
            Real = Real+1;
        else %seizure files
            for q = 1:file_size{1,patient_num(i)}
                if Numbers(Seiz) == annotation(q+AnnoNum{patient_num(i)}-1,2)
                    while Numbers(Seiz) == annotation(q+Multiple+AnnoNum{patient_num(i)}-1,2) 
                        for jp = 1:30
                            if j+a==1
                                Random_S = randi([annotation(q+Multiple+AnnoNum{patient_num(i)}-1,3) annotation(q+Multiple+AnnoNum{patient_num(i)}-1,4)-5],1,1);
                                anno(Random_S:Random_S+5) = 1;
                            else
                                Other_S = randi([File_Lengths(j-1+a)+annotation(q+Multiple+AnnoNum{patient_num(i)}-1,3) File_Lengths(j-1+a)+annotation(q+Multiple+AnnoNum{patient_num(i)}-1,4)-5],1,1);
                                anno(Other_S:Other_S+5) = 1;
                            end
                        end
                        Multiple = Multiple+1;
                        if Multiple == MAX+1
                            continue
                        end
                    end
                    Multiple = 0;
                end
            end
            Seiz = Seiz+1;
        end
    end
    a=a+size(True,1);
    
    NON_files{patient_num(i)} = erase(NON_files{patient_num(i)},True);
    NON_files{patient_num(i)}(all(cellfun('isempty',NON_files{patient_num(i)}),2),:) = [];
    
    S_files{patient_num(i)} = erase(S_files{patient_num(i)},True);
    S_files{patient_num(i)}(all(cellfun('isempty',S_files{patient_num(i)}),2),:) = [];
end
%----------------------------------------------------------------------
%----------------------------------------------------------------------
%PART 2: Extract the RP Features

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

%----------------------------------------------------------------------
%----------------------------------------------------------------------
%Part 3.5: Viewing purposes only, can be commented out if we want:
%figure
%for p = 1:8
%   cfeature = num2str(p);
%
%   MyTitle = strcat('Feature:', {' '}, cfeature);
%   subplot(3,3,p), plot(A1(p,:)), hold on, plot(anno(phase1start:phase1end),'r'),set(gca,'XTick',(0:3600:c),'XTickLabel',[0:1:c/3600]),xlabel('Time (hours)'), ylabel('Relative Phase'), title(MyTitle);

% end

%----------------------------------------------------------------------
%----------------------------------------------------------------------
%Part 4: Create Training Data:
Train = [Train, [anno(phase1start:phase1end);snowball(:,phase1start:phase1end);snowphase;RP]];
toc; %tells us how long a run takes
%beep


Train= Train';
features = [Train(:,2:end-8)];
classLabels = [Train(:,1)];
% How many trees do you want in the forest? 
nTrees = 10;
 
% Train the TreeBagger (Decision Forest).
Fin = TreeBagger(nTrees,features,classLabels,'OOBPredictorImportance','On','PredictorSelection','curvature', 'Method', 'classification');
imp = Fin.OOBPermutedPredictorDeltaError;

%impOOB = oobPermutedPredictorImportance(Fin);
%{
figure;
bar(imp);
title('Curvature Test');
ylabel('Predictor importance estimates');
xlabel('Predictors');
h = gca;
set(gca, 'XTick', 1:length(Fin.PredictorNames))
xticklabels(Fin.PredictorNames);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
%}
Predictors = [Fin.PredictorNames; num2cell(imp)];
Predictors = Predictors';
Predictors = flipud(sortcell(Predictors, 2));
Pvalues = regexp(Predictors(:,1),'\d*','Match');

cd('C:\Users\chand_000\Documents\Excel Files for R');
Heading = [cellstr('Y') cellstr('X1') cellstr('X2') cellstr('X3') cellstr('X4') cellstr('X5') cellstr('X6') cellstr('X7') cellstr('X8') cellstr('X9') cellstr('X10') cellstr('X11') cellstr('X12') cellstr('X13') cellstr('X14') cellstr('X15') cellstr('X16') cellstr('X17') cellstr('X18') cellstr('X19') cellstr('X20') cellstr('X21') cellstr('X22') cellstr('X23') cellstr('X24')];
filename = strcat('training-chb',num2str(patient_num),'.xlsx');
xlswrite(filename, Heading)
xlswrite(filename,Train, ['A2:Y' num2str(size(Train,1)+1)]);


%testingData1