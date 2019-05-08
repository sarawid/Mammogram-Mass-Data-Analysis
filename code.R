


library("rpart")
library("rattle")
library("MixGHD")
library("RColorBrewer")
library("rpart.plot")
library("nnet")

######################################################
##Preparing the Raw data for cleaning
#filtered out all missing data and non sensible data

data=read.csv("http://archive.ics.uci.edu/ml/machine-learning-databases/mammographic-masses/mammographic_masses.data", header=TRUE)
colnames(data)=c("BIRADS", "Age", "", "Margin", "Density", "Severity")

mgm3=data
is.na(mgm3) <- mgm3=='?'  #assign na to all "?" in the dataset
mgm = mgm3[complete.cases(mgm3),]  #dropping missing data


mgm[257,1]=5  # this value was essentially 55 but I figured it was a type so I assigned a value of 5 to it.
rownames(mgm) <- NULL # re ordered the dataframe


#######################################################
#Classification Tree
set.seed(616)
#NOTE you may see different output in the report compared to the code output below due to different seed number.
mgm_train <- c(sample(1:829, 414))
#^our training data set
mgm_tree <- rpart(Severity ~ ., data = mgm, subset=mgm_train,  method="class")
#^Classification tree
printcp(mgm_tree)
table(predict(mgm_tree, mgm[-mgm_train,], type = "class"),
      mgm[-mgm_train, "Severity"])
#^Prediction table      
      
fancyRpartPlot(mgm_tree)
#Classification tree plot

######################################################
#LOGESTIC REGRESSION
train=mgm[1:414,]
test=mgm[415:829,]

model <-glm(Severity ~.,family=binomial(link='logit'),data= train)

summary(model)

#odds Ratio
exp(cbind(OR = coef(model), confint.default(model)))
G<-537.84-307.24
pchisq(G,5,lower.tail=FALSE)

anova(model, test="Chisq")
#^Analysis of Deviance 


###ROC

p <- predict(model, test, type="response")
pr <- prediction(p, test$Severity)
prf <- performance(pr, measure = "tpr", x.measure = "fpr")

plot(prf)
auc <- performance(pr, measure = "auc")
auc <- auc@y.values[[1]]
auc #[1] 0.887799

######################################################
##PCA FOR FUN


mgm.pca <- prcomp(mgm[,-6],
              
                 scale. = TRUE) 
print(mgm.pca)
summary(mgm.pca)
plot(mgm.pca, type = "l")