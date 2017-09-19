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


# Multinomial regression with 95% sparse terms removed
data.95 <- remSparse(.95)
data.95.train <- data.frame(data.95[1:981,], sentiment = train.data$sentiment)
data.95.test <- data.frame(data.95[982:1960,])

mn95 <- glm(sentiment ~ ., data = data.95.train)
mn95.preds <- predict(mn95, newdata= data.95.test, "response")
x<-floor(mn95.preds)

sum(x==3)/length(mn95.preds) # all 3s

#LOOCV 
coef(mn95)
library(boot)
cv.err = cv.glm(data.95.train, mn95)
cv.err$delta
#Cross validation estimate for the test error:
#Test MSE
#[1] 0.6228974 0.6228932

#testing higher order polynomials
cv.error = rep(0,5)
for (i in 1:5) {
  mn95 <- glm(sentiment ~ ., data = data.95.train)
  cv.error[i] = cv.glm(data.95.train, mn95)$delta[1]
}
cv.error
#Test MSE
#[1] 0.6228974 0.6228974 0.6228974 0.6228974 0.6228974
#no change in Test MSE for increasingly complex polynomials





# ===========================================================================================
predictions <- data.frame(id=test.data$id, sentiment=mn95.preds)
write.table(predictions.mn.995, file = "linreg-predictions-3.csv", row.names=F, col.names=c("id", "sentiment"), sep=",")
