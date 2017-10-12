Accuracy = [0.9039; .7198; .9752];
Sensitivity = [0.5974; 0.4013; 0.498];
Specificity = [0.9081; 0.7254; 0.9828];
Accuracy = Accuracy*100;
Specificity = Specificity*100;
Sensitivity = Sensitivity*100;
x = [Accuracy Sensitivity Specificity];
y = [cellstr('Accuracy'); cellstr('Accuracy'); cellstr('Accuracy'); cellstr('Sensitivity'); cellstr('Sensitivity'); cellstr('Sensitivity'); cellstr('Specificity'); cellstr('Specificity'); cellstr('Specificity')];
boxplot(x,y)
ylim([0 100])
