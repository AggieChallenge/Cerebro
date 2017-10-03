import java.net.Socket
import java.io.*

% Since TreeBagger uses randomness we will get different results each 
% time we run this.
% This makes sure we get the same results every time we run the code.
rng default

% Here we create some training data.
% The rows&lt; represent the samples or individuals.
% The last 14 columns represent the individual's features.
% The first column represents the class label (what we want to predict)
%Train = [Train8;Train7(2:9,:);Train12(2:9,:);Train13(2:9,:);Train11(2:9,:)]';
%Test = [Test8;Test7(2:9,:);Test12(2:9,:);Test13(2:9,:);Test11(2:9,:)]';

Train= Train';
features = [Train(str2num(Pvalues{1}{1})+1,:); Train(str2num(Pvalues{2}{1})+1,:); Train(str2num(Pvalues{3}{1})+1,:); Train(str2num(Pvalues{4}{1})+1,:); Train(str2num(Pvalues{5}{1})+1,:); Train(str2num(Pvalues{6}{1})+1,:); Train(str2num(Pvalues{7}{1})+1,:);...
    Train(str2num(Pvalues{8}{1})+1,:); Train(str2num(Pvalues{9}{1})+1,:); Train(str2num(Pvalues{10}{1})+1,:)];
features = features';
classLabels = [Train(1,:)];
classLabels = classLabels';
% How many trees do you want in the forest? 
nTrees = 10;
 
% Train the TreeBagger (Decision Forest).
Mdl = TreeBagger(nTrees,features,classLabels,'OOBPredictorImportance','On','PredictorSelection','curvature', 'Method', 'classification');

imp = Mdl.OOBPermutedPredictorDeltaError;

%impOOB = oobPermutedPredictorImportance(Mdl);
%{
figure;
bar(imp);
title('Curvature Test');
ylabel('Predictor importance estimates');
xlabel('Predictors');
h = gca;
set(gca, 'XTick', 1:length(Mdl.PredictorNames))
xticklabels(Mdl.PredictorNames);
h.XTickLabelRotation = 45;
h.TickLabelInterpreter = 'none';
%}
%t = templateTree('NumPredictorsToSample','all',...
%    'PredictorSelection','interaction-curvature','Surrogate','on');
%rng(1); % For reproducibility

 
% Given a new individual WITH the features and WITHOUT the class label,
% what should the class label be?
newData1 = [Test(str2num(Pvalues{1}{1})+1,:); Test(str2num(Pvalues{2}{1})+1,:); Test(str2num(Pvalues{3}{1})+1,:); Test(str2num(Pvalues{4}{1})+1,:); Test(str2num(Pvalues{5}{1})+1,:); Test(str2num(Pvalues{6}{1})+1,:); Test(str2num(Pvalues{7}{1})+1,:);...
    Test(str2num(Pvalues{8}{1})+1,:); Test(str2num(Pvalues{9}{1})+1,:); Test(str2num(Pvalues{10}{1})+1,:)];
newData1 = newData1';
% Use the trained Decision Forest and probability is recorded in scores.
[predChar1,scores] = Mdl.predict(newData1);

% Predictions is a char though. We want it to be a number.
predictedClass = str2double(predChar1);
Test = Test';
C1 = confusionmat(Test(:,1),predictedClass)
stats = confusionmatStats(C1); %To get stats using user made function
Accuracy = stats.accuracy(2) 
stats.precision(2) 
Sensitivity = stats.sensitivity(2)
Specificity = stats.specificity(2)
SCORES = Mdl.OOBPermutedPredictorDeltaError'; %Larger the value, the more important it is
%figure, plot(predictedClass), hold on, plot(Test(:,1),'r'), hold on, set(gca,'XTick',(0:3600:size(Test,1)),'XTickLabel',[0:1:size(Test,1)/3600]),xlabel('Time (hours)'), ylabel('Predicted Class'), ylim([-0.5 1.5]), title('Predicted Class Graph');
figure, plot(scores(:,2)), hold on, plot(Test(:,1),'r'), hold on, set(gca,'XTick',(0:3600:size(Test,1)),'XTickLabel',[0:1:size(Test,1)/3600]),xlabel('Time (hours)'), ylabel('Predicted Class'), ylim([-0.5 1.5]), title('Probability Estimation Graph');
beep

%%
for t = 1:size(scores,1) 
    if scores(t,2) > 0.2
        probClass(t) = 1;
    else
        probClass(t) = 0;
    end
end
probClass = probClass';
C2 = confusionmat(Test(:,1),probClass)
stats = confusionmatStats(C2); %To get stats using user made function
stats.accuracy(2) 
stats.precision(2) 
stats.sensitivity(2)
stats.specificity(2)
figure, plot(probClass), hold on, plot(Test(:,1),'r'), hold on, set(gca,'XTick',(0:3600:size(Test,1)),'XTickLabel',[0:1:size(Test,1)/3600]),xlabel('Time (hours)'), ylabel('Predicted Class'), ylim([-0.5 1.5]), title('Probability Estimation Graph');

if Sensitivity > 0.5
    message      = '1';
else
    message = '0';
    
output_socket = [];
host = '10.110.6.228';
port = 3000;
    
for i = 1:1
    
    try
        fprintf(1, 'Connecting to %s:%d\n', host, port);
        
        output_socket = Socket(host, port);
        
        output_stream   = output_socket.getOutputStream;
        d_output_stream = DataOutputStream(output_stream);
        
        fprintf(1, 'Connected\n');
        
        fprintf(1, 'Writing %d bytes\n', length(message))
        d_output_stream.writeUTF(char(message));
        d_output_stream.flush;
        fprintf('Done\n');
        
        server_socket.close;
        output_socket.close;
        break;
        
    catch
        if ~isempty(output_socket)
            output_socket.close;
        end
    end
end
end
    