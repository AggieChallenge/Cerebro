Accuracy = [0.9638];
Sensitivity = [0.4537];
Specificity = [0.9819];
Accuracy = Accuracy*100;
Specificity = Specificity*100;
Sensitivity = Sensitivity*100;
x = [Accuracy Sensitivity Specificity];
y = [cellstr('Accuracy'); cellstr('Sensitivity'); cellstr('Specificity')];
boxplot(x,y)
ylim([0 100])
title('Patient 1')