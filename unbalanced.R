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

training$Y <- as.factor(training$Y)
rf.chb01=randomForest(training$Y~.,data=training,ntree=10, type=classification, importance=TRUE,proximity=TRUE) ##Afr#attach(testing_chb01)

chb01.pred=predict(rf.chb01,newdata=testing[,2:25]) #gives the output of the model, how it predicts

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

