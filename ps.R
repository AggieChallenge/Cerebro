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

print(table(training$Y))

training_bal <- ubSMOTE(X=training[,2:ncol(training)],Y=training$Y,  perc.over = 5000,perc.under = 1, verbose = TRUE)
training_bal<- data.frame(cbind( training_bal$Y, training_bal$X))
training_bal$training_bal.Y<- ifelse(training_bal$training_bal.Y==1,0,1)
print(table(training_bal$training_bal.Y))
# write.csv(training_bal, "Patient_train.csv")
  
#SMOTE testing data
# testing=as.data.frame(testing)
# library(DMwR)
# set.seed(1)
# testing$Y <- as.factor(testing$Y)
# testing_bal <- ubSMOTE(X=testing[,2:ncol(testing)],Y=testing$Y,  perc.over =3000,perc.under = 10, verbose = TRUE)
# testing_bal<- data.frame(cbind( testing_bal$Y, testing_bal$X))
# testing_bal$testing_bal.Y<- ifelse(testing_bal$testing_bal.Y==1,0,1)
# print(table(testing_bal$testing_bal.Y))
# write.csv(testing_bal, "Patient_test.csv")

training <- training_bal
training$Y<-training_bal$training_bal.Y
training$training_bal.Y=NULL

#testing <- testing_bal
#testing$Y<-testing_bal$testing_bal.Y
#testing$testing_bal.Y=NULL

names(training)
training$Y <- as.factor(training$Y)
rf.chb01=randomForest(training$Y~.,data=training,ntree=10, type=classification, importance=TRUE,proximity=TRUE) ##Afr#attach(testing_chb01)
chb01.pred=predict(rf.chb01,newdata=testing[,2:25]) #gives the output of the model, how it predicts
# 0 to 1, flip with 3 pts
# 1 to 0, flip with 5 pts
# on balanced training
# on unbalanced testing
# new parse the output
table(chb01.pred)
for (i in 3:(length(chb01.pred)-2)) #flipping from 1 to 0 with 5 point parsing
{
  if ((chb01.pred[i-1]==chb01.pred[i+1])&&(chb01.pred[i]!=chb01.pred[i-1])&&(chb01.pred[i-2]==chb01.pred[i+2])&&(chb01.pred[i-2]==0))
    chb01.pred[i]=chb01.pred[i-1]
}
for (i in 2:(length(chb01.pred)-1)) #flipping from 0 to 1 with 3 point parsing
{
  if ((chb01.pred[i-1]==chb01.pred[i+1])&&(chb01.pred[i]!=chb01.pred[i-1])&&(chb01.pred[i-1]==1))
    chb01.pred[i]=chb01.pred[i-1]
}
table(chb01.pred)
table(testing$Y)

confusionMatrix(chb01.pred, testing$Y)
