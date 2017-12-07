library(randomForest)
library(caret)
library(xlsx)
library(rJava)
library(unbalanced)

installed(1)

setwd("C:\\Users\\chand_000\\Documents\\Excel Files for R")
training<- read.csv("training-ch.csv", header = TRUE)
testing<- read.csv("testing-chb.csv", header = TRUE)

print(table(training$Y))
print(table(testing$Y))

#SMOTE training data
training=as.data.frame(training)
library(DMwR)
set.seed(1)
training$Y <- as.factor(training$Y)
training_bal <- ubSMOTE(X=training[,2:ncol(training)],Y=training$Y,  perc.over = 12000,perc.under = 10, verbose = TRUE)
training_bal<- data.frame(cbind( training_bal$Y, training_bal$X))
#training_bal$Y<- as.numeric(training_bal$training_bal.Y)
#training_bal$training_bal.Y=NULL
training_bal$training_bal.Y<- ifelse(training_bal$training_bal.Y==1,0,1)
#out<- training_bal$Y
#training_bal[,25]<- training_bal[,1]
#training_bal[,1]<-out
dim(training_bal)
print(table(training_bal$training_bal.Y))
write.csv(training_bal, "Patient_train.csv")
  
#SMOTE testing data
testing=as.data.frame(testing)
library(DMwR)
set.seed(1)
testing$Y <- as.factor(testing$Y)
testing_bal <- ubSMOTE(X=testing[,2:ncol(testing)],Y=testing$Y,  perc.over =11000,perc.under = 10, verbose = TRUE)
testing_bal<- data.frame(cbind( testing_bal$Y, testing_bal$X))
#testing_bal$Y<- as.numeric(testing_bal$testing_bal.Y)
#testing_bal$testing_bal.Y=NULL
testing_bal$testing_bal.Y<- ifelse(testing_bal$testing_bal.Y==1,0,1)
#out<- testing_bal$Y
#testing_bal[,25]<- testing_bal[,1]
#testing_bal[,1]<-out
dim(testing_bal)
print(table(testing_bal$testing_bal.Y))
write.csv(testing_bal, "Patient_test.csv")

#training_chb01 <- SMOTE(Y ~ .,training_chb01,perc.over =200, perc.under = 100)
#training_chb01$Y <- as.numeric(training_chb01$Y)
#print(prop.table(table(training_chb01$Y)))
#dim(training_chb01)
#SMOTE testing data
#testing_chb01=as.data.frame(testing_chb01)
#library(DMwR)
#set.seed(1)
#testing_chb01$Y <- as.factor(testing_chb01$Y)
#testing_chb01 <- SMOTE(Y ~ .,testing_chb01,perc.over = 50,perc.under=100)
#testing_chb01$Y <- as.numeric(testing_chb01$Y)
#print(prop.table(table(testing_chb01$Y)))
#set.seed(1)
#training_chb01$Y<- as.factor(training_chb01$Y)
#rf.chb01=randomForest(Y~.,data=training_chb01,importance=TRUE,proximity=TRUE)
#attach(testing_chb01)
#testing_chb01$Y<- as.numeric(testing_chb01$Y)
#set.seed(1)
#testing_chb01$Y=as.factor(testing_chb01$Y)
#chb01.pred=predict(rf.chb01,newdata=(testing_chb01[,-Y])) #gives the output of the model, how it predicts
#chb01.pred=as.numeric(chb01.pred)
#testing_chb01$Y<- as.factor(testing_chb01$Y) #how it is actually, subject chb01.pred to parsing
#training_chb01$Y<- as.numeric(training_chb01$Y) 

#library(pROC)
#set.seed(1)
#auc <- roc(testing_chb01$Y, chb01.pred)
#print(auc)


training <- training_bal
training$Y<-training_bal$training_bal.Y
training$training_bal.Y=NULL

testing <- testing_bal
testing$Y<-testing_bal$testing_bal.Y
testing$testing_bal.Y=NULL

names(training)
training$Y <- as.factor(training$Y)
rf.chb01=randomForest(training$Y~.,data=training,ntree=10, type=classification, importance=TRUE,proximity=TRUE) ##Afr#attach(testing_chb01)
chb01.pred=predict(rf.chb01,newdata=testing[,1:24]) #gives the output of the model, how it predicts

table(chb01.pred)
for (i in 2:(length(chb01.pred)-1))
{
  if ((chb01.pred[i-1]==chb01.pred[i+1])&&(chb01.pred[i]!=chb01.pred[i-1]))
    chb01.pred[i]=chb01.pred[i-1]
}
table(chb01.pred)
table(testing$Y)

confusionMatrix(chb01.pred, testing$Y)
