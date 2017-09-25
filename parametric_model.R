library(tm)
library(tidyverse)
library(nnet)

# read in data
train.data <- read_csv("train.csv")
test.data <- read_csv("test.csv")

# create data frame from train and test data so we can create a document matrix
# that incorporates words from both train and test 
document.data.frame <- rbind(train.data[,2], test.data[,2])

# convert data frame to a corpus object.
tweets <- VCorpus(DataframeSource(document.data.frame))

# there's a lot in the documents that we don't care about. clean up the corpus.
tweets.clean <- tm_map(tweets, stripWhitespace)                          # remove extra whitespace
tweets.clean <- tm_map(tweets.clean, removeNumbers)                      # remove numbers
tweets.clean <- tm_map(tweets.clean, removePunctuation)                  # remove punctuation
tweets.clean <- tm_map(tweets.clean, content_transformer(tolower))       # ignore case
tweets.clean <- tm_map(tweets.clean, removeWords, stopwords("english"))  # remove stop words
tweets.clean <- tm_map(tweets.clean, stemDocument)                       # stem all words

# TF-IDF matrix
tweets.clean.tfidf = DocumentTermMatrix(tweets.clean, control = list(weighting = weightTfIdf))

# function that removes sparse terms based on proportion (0-1)
remSparse <- function (perc) {
  tfidf <- removeSparseTerms(tweets.clean.tfidf, perc)
  data <- data.frame(as.matrix(tfidf))
  
  # remove obvious words: car, driverless, googl, googleìââã
  if("car" %in% colnames(data)) {data.new <- subset(data, select=-car)}
  if("driverless" %in% colnames(data)) {data.new <- subset(data.new, select=-driverless)}
  if("googl" %in% colnames(data)) {data.new <- subset(data.new, select=-googl)}
  if("googleìââã" %in% colnames(data)) {data.new <- subset(data.new, select=-googleìââã)}
  return(data.new)
}

# ===========================================================================================

# For our parametric model, we considered two regression models. The first is a simple linear 
# regression model. The second is a multinomial regression model, which can predict
# classification-type data by calculating the probability that each observation will fall
# into each classification category. It seems appropriate to explore the multinomial regression
# because output variable "sentiment" is a categorical variable.

# In order to implement LOOCV with multinomial regression, we coded an LOOCV function
# from scratch. In order to be able to compare our test error from multionmial regression with
# the test error from simple linear regression, we also implemented LOOCV from scratch for
# simple linear regression.

# LOOCV function for multinomial regression

multinom.loocv <- function(data) {
  numcorrect <- 0
  sink("/dev/null") # hide console output
  
  for (i in 1:nrow(data)) {
    test <- data[i,] # get test observation
    train <- data[-i,] # the rest of the data are treated as training set
    mn <- multinom(sentiment ~ ., data = train) # get multinomial regression
    pred <- predict(mn, newdata=test, "class") # predict sentiment of test observation
    if (pred==test$sentiment) {numcorrect <- numcorrect + 1} # count the number of correct predictions
  }
  
  sink()
  return(numcorrect/nrow(data)) # proportion of correct predictions
}

# LOOCV function for simple linear regression

lm.loocv <- function(data) {
  numcorrect <- 0
  
  for (i in 1:nrow(data)) {
    test <- data[i,]
    train <- data[-i,]
    lm <- lm(sentiment ~ ., data = train)
    pred <- predict(lm, newdata=test, type="response")
    pred <- round(pred, 0)
    if (pred==test$sentiment) {numcorrect <- numcorrect + 1}
  }
  
  return(numcorrect/nrow(data))
}

# ===========================================================================================

# Below, we implement LOOCV for simple linear and multinomial regression several times.
# Each time, we remove a greater amount of sparse terms from the matrix, and look at
# the proportion of correct predictions made.

# TFIDF WITH 98% SPARSE TERMS REMOVED
data.98 <- remSparse(.98)
data.98.train <- data.frame(data.98[1:981,], sentiment = train.data$sentiment)

# simple linear
perc_lm98 <- lm.loocv(data.98.train)
perc_lm98 # 0.6106014

# multinomial
perc_correct98 <- multinom.loocv(data.98.train)
perc_correct98 # 0.5922528

# TFIDF WITH 97% REMOVED
data.97 <- remSparse(.97)
data.97.train <- data.frame(data.97[1:981,], sentiment = train.data$sentiment)

# simple linear
perc_lm97 <- lm.loocv(data.97.train)
perc_lm97 # 0.6106014

# multinomial
perc_correct97 <- multinom.loocv(data.97.train)
perc_correct97 # 0.6034659

# TFIDF WITH 96% REMOVED
data.96 <- remSparse(.96)
data.96.train <- data.frame(data.96[1:981,], sentiment = train.data$sentiment)

# simple linear
perc_lm96 <- lm.loocv(data.96.train)
perc_lm96 # 0.6146789

# multinomial
perc_correct96 <- multinom.loocv(data.96.train)
perc_correct96 # 0.6126402

# TFIDF WITH 95% REMOVED
data.95 <- remSparse(.95)
data.95.train <- data.frame(data.95[1:981,], sentiment = train.data$sentiment)

# simple linear
perc_lm95 <- lm.loocv(data.95.train)
perc_lm95 # 0.6146789

# multinomial
perc_correct95 <- multinom.loocv(data.95.train)
perc_correct95 # 0.6136595

# TFIDF WITH 94% REMOVED
data.94 <- remSparse(.94)
data.94.train <- data.frame(data.94[1:981,], sentiment = train.data$sentiment)

# simple linear
perc_lm94 <- lm.loocv(data.94.train)
perc_lm94 # 0.6146789

# multinomial
perc_correct94 <- multinom.loocv(data.94.train)
perc_correct94 # 0.6136595

# TFIDF WITH 93% REMOVED
data.93 <- remSparse(.93)
data.93.train <- data.frame(data.93[1:981,], sentiment = train.data$sentiment)

# multinomial
perc_correct93 <- multinom.loocv(data.93.train)
perc_correct93 # 0.6136595

# The test errors of both multinomial and simple linear regression improve as we remove
# more terms from the document-term matrix. However, after scrutnizing our results, we
# realized that as we remove more terms from the matrix, the more both regression methods
# are likely to predict 3's. In fact, roughtly 61.5% of our training data consists of 3's.
# By the time we remove terms that are absent from 96% of all tweets, the linear model
# is already outputting all 3's and stays that way as we continue removing more terms.
# The multinomial model also asymptotically moves towards an output that consists of all
# 3's.

# It is disappointing that we cannot improve our test error beyond this point. Nonetheless,
# the output of almost all 3's (i.e. the mode sentiment) is fairly predictive, as we managed
# to correctly predict over 60% of our test observations using these regressions.

# ===========================================================================================

# linear model with 90% sparse terms removed

data <- remSparse(.93)
train <- data.frame(data[1:981,], sentiment = train.data$sentiment)
test <- data[982:nrow(data),]

model <- lm(sentiment~., data=train)
preds <- predict(model, newdata=test, type="response")
preds.rounded <- round(preds, 0)

sum(preds.rounded==3)/length(preds.rounded) # 99.69356 of all predictions are 3's

# multinomial regression with 94% sparse terms removed
data.mn <- remSparse(.94)
data.mn.train <- data.frame(data.mn[1:981,], sentiment = train.data$sentiment)
data.mn.test <- data.frame(data.mn[982:1960,])

mn <- multinom(sentiment ~ ., data = data.mn.train)
mn.preds <- predict(mn, newdata=data.mn.test, "class")

sum(mn.preds==3)/length(mn.preds) # 94.48417% of all predictions are 3's

# ===========================================================================================
predictions <- data.frame(id=test.data$id, sentiment=preds.rounded)
write.table(predictions, file = "lin-predictions.csv", row.names=F, col.names=c("id", "sentiment"), sep=",")