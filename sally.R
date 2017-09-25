library(tm)
library(tidyverse)
library(nnet)

train.data <- read_csv("train.csv")
test.data <- read_csv("test.csv")

document.data.frame <- rbind(train.data[,2], test.data[,2])

# convert data frame to a corpus object.
tweets <- VCorpus(DataframeSource(document.data.frame))

##### Reducing Term Sparsity #####
# there's a lot in the documents that we don't care about. clean up the corpus.
tweets.clean <- tm_map(tweets, stripWhitespace)                          # remove extra whitespace
tweets.clean <- tm_map(tweets.clean, removeNumbers)                      # remove numbers
tweets.clean <- tm_map(tweets.clean, removePunctuation)                  # remove punctuation
tweets.clean <- tm_map(tweets.clean, content_transformer(tolower))       # ignore case
tweets.clean <- tm_map(tweets.clean, removeWords, stopwords("english"))  # remove stop words
tweets.clean <- tm_map(tweets.clean, stemDocument)                       # stem all words

# TF-IDF matrix
tweets.clean.tfidf = DocumentTermMatrix(tweets.clean, control = list(weighting = weightTfIdf))

# function that removes sparse terms based on percentage (0-1)
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
# LOOCV function for multinomial regression

multinom.loocv <- function(data) {
  numcorrect <- 0
  sink("/dev/null")
  
  for (i in 1:nrow(data)) {
    test <- data[i,]
    train <- data[-i,]
    mn <- multinom(sentiment ~ ., data = train)
    pred <- predict(mn, newdata=test, "class")
    if (pred==test$sentiment) {numcorrect <- numcorrect + 1}
  }
  
  sink()
  return(numcorrect/nrow(data))
}

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

# TFIDF WITH 98% REMOVED
data.98 <- remSparse(.98)
data.98.train <- data.frame(data.98[1:981,], sentiment = train.data$sentiment)

perc_lm98 <- lm.loocv(data.98.train)
perc_lm98 # 0.6106014

perc_correct98 <- multinom.loocv(data.98.train)
perc_correct98 # 0.5922528

# TFIDF WITH 97% REMOVED
data.97 <- remSparse(.97)
data.97.train <- data.frame(data.97[1:981,], sentiment = train.data$sentiment)

perc_lm97 <- lm.loocv(data.97.train)
perc_lm97 # 0.6106014

perc_correct97 <- multinom.loocv(data.97.train)
perc_correct97 # 0.6034659

# TFIDF WITH 96% REMOVED
data.96 <- remSparse(.96)
data.96.train <- data.frame(data.96[1:981,], sentiment = train.data$sentiment)

perc_lm96 <- lm.loocv(data.96.train)
perc_lm96 # 0.6146789

perc_correct96 <- multinom.loocv(data.96.train)
perc_correct96 # 0.6126402

# TFIDF WITH 95% REMOVED
data.95 <- remSparse(.95)
data.95.train <- data.frame(data.95[1:981,], sentiment = train.data$sentiment)

perc_lm95 <- lm.loocv(data.95.train)
perc_lm95 # 0.6146789

perc_correct95 <- multinom.loocv(data.95.train)
perc_correct95 # 0.6136595

# TFIDF WITH 94% REMOVED
data.94 <- remSparse(.94)
data.94.train <- data.frame(data.94[1:981,], sentiment = train.data$sentiment)

perc_lm94 <- lm.loocv(data.94.train)
perc_lm94 # 0.6146789

perc_correct94 <- multinom.loocv(data.94.train)
perc_correct94 # 0.6136595

# TFIDF WITH 93% REMOVED
data.93 <- remSparse(.93)
data.93.train <- data.frame(data.93[1:981,], sentiment = train.data$sentiment)

perc_correct93 <- multinom.loocv(data.93.train)
perc_correct93 # 0.6136595

# ===========================================================================================

# linear model with 90% sparse terms removed
data <- remSparse(.93)
train <- data.frame(data[1:981,], sentiment = train.data$sentiment)
test <- data[982:nrow(data),]

model <- lm(sentiment~., data=train)
preds <- predict(model, newdata=test, type="response")
preds.rounded <- round(preds, 0)

sum(preds.rounded==3)/length(preds.rounded) # 0.9969356

# multinomial regression with 94% sparse terms removed
data.mn <- remSparse(.94)
data.mn.train <- data.frame(data.mn[1:981,], sentiment = train.data$sentiment)
data.mn.test <- data.frame(data.mn[982:1960,])

mn <- multinom(sentiment ~ ., data = data.mn.train)
mn.preds <- predict(mn, newdata=data.mn.test, "class")

sum(mn.preds==3)/length(mn.preds) # 0.9448417

# ===========================================================================================
predictions <- data.frame(id=test.data$id, sentiment=preds.rounded)
write.table(predictions, file = "lin-predictions.csv", row.names=F, col.names=c("id", "sentiment"), sep=",")