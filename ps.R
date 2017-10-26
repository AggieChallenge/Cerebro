library(randomForest)
library(caret)
library(xlsx)
library(rJava)
library(unbalanced)

installed(1)

training_chb01<- read.csv("training-chb01.csv", header = TRUE)

print(table(training_chb01$Y))
#print(table(testing_chb01$Y))

#SMOTE training data
training_chb01=as.data.frame(training_chb01)
library(DMwR)
set.seed(1)
training_chb01$Y <- as.factor(training_chb01$Y)
training_bal <- ubSMOTE(X=training_chb01[,2:ncol(training_chb01)],Y=training_chb01$Y,  perc.over =500,perc.under = 125, verbose = TRUE)
training_bal<- data.frame(cbind(training_bal$X, training_bal$Y))
training_bal$Y<- as.numeric(training_bal$training_bal.Y)
training_bal$training_bal.Y=NULL
training_bal$Y<- ifelse(training_bal$Y==1,0,1)
dim(training_bal)
print(table(training_bal$Y))
write.csv()
  
training_chb01 <- SMOTE(Y ~ .,training_chb01,perc.over =200, perc.under = 100)
training_chb01$Y <- as.numeric(training_chb01$Y)
print(prop.table(table(training_chb01$Y)))
dim(training_chb01)
#SMOTE testing data
testing_chb01=as.data.frame(testing_chb01)
library(DMwR)
set.seed(1)
testing_chb01$Y <- as.factor(testing_chb01$Y)
testing_chb01 <- SMOTE(Y ~ .,testing_chb01,perc.over = 50,perc.under=100)
testing_chb01$Y <- as.numeric(testing_chb01$Y)
print(prop.table(table(testing_chb01$Y)))
set.seed(1)
training_chb01$Y<- as.factor(training_chb01$Y)
rf.chb01=randomForest(Y~.,data=training_chb01,importance=TRUE,proximity=TRUE)
attach(testing_chb01)
testing_chb01$Y<- as.numeric(testing_chb01$Y)
set.seed(1)
testing_chb01$Y=as.factor(testing_chb01$Y)
chb01.pred=predict(rf.chb01,newdata=(testing_chb01[,-Y])) #gives the output of the model, how it predicts
chb01.pred=as.numeric(chb01.pred)
testing_chb01$Y<- as.factor(testing_chb01$Y) #how it is actually, subject chb01.pred to parsing
training_chb01$Y<- as.numeric(training_chb01$Y) 

library(pROC)
set.seed(1)
auc <- roc(testing_chb01$Y, chb01.pred)
print(auc)

confusionMatrix(chb01.pred, testing_chb01$Y)

for (i in 2:(length(chb01.pred)-1))
{
  if ((chb01.pred[i-1]==chb01.pred[i+1])&&(chb01.pred[i]!=chb01.pred[i-1]))
    chb01.pred[i]=chb01.pred[i-1]
}
library(pROC)
set.seed(1)
auc <- roc(testing_chb01$Y, chb01.pred)
print(auc)

confusionMatrix(chb01.pred, testing_chb01$Y)
library(reprtree)
reprtree:::plot.getTree(rf.chb01)
plot((auc),col="green", lwd=3, main="ROC Curve")
partialPlot(rf.chb01,training_chb01,x.var = X4 , which.class=2,xlab=deparse(substitute(X4)), ylab="Partial Dependence",main=paste("Partial Dependence on", deparse(substitute(X4))))
varImpPlot(rf.chb01,type=2)
