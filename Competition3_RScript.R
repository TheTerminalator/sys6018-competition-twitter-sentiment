
library(readr)
library(XML)
library(tm)

twitter <- read_csv("train.csv") #Loading in data set

twitter_c = VCorpus(DataframeSource(twitter))
#document.data.frame = as.data.frame(document.data.frame[,"c"], stringsAsFactors = FALSE)

inspect(twitter_c[1:2])
twitter_c[[1]]

# compute TF-IDF matrix and inspect sparsity
twitter.tfidf = DocumentTermMatrix(twitter_c, control = list(weighting = weightTfIdf))
twitter.tfidf  # non-/sparse entries indicates how many of the DTM cells are non-zero and zero, respectively.
# sparsity is number of non-zero cells divided by number of zero cells.

twitter.tfidf[1:5,1:5]
as.matrix(twitter.tfidf[1:5,1:5])

# there's a lot in the documents that we don't care about. clean up the corpus.
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
twitter.clean = tm_map(twitter_c, content_transformer(removeURL))
removeAT <- function(x) gsub("@[^[:space:]]*", "", x)
twitter.clean = tm_map(twitter.clean, content_transformer(removeAT))
twitter.clean = tm_map(twitter.clean, stripWhitespace)                          # remove extra whitespace
#twitter.clean = tm_map(twitter.clean, removeNumbers)                      # remove numbers
twitter.clean = tm_map(twitter.clean, removePunctuation)                  # remove punctuation
twitter.clean = tm_map(twitter.clean, content_transformer(tolower))       # ignore case
twitter.clean = tm_map(twitter.clean, removeWords, stopwords("english"))  # remove stop words
twitter.clean = tm_map(twitter.clean, stemDocument) 


# compare original content of document 1 with cleaned content
twitter_c[[1]]$content
twitter.clean[[1]]$content  # do we care about misspellings resulting from stemming?
twitter.clean[[14]]$content 
twitter.clean.tfidf = DocumentTermMatrix(twitter.clean, control = list(weighting = weightTfIdf))


# reinspect the first 5 documents and first 5 terms
twitter.clean.tfidf[1:5,1:5]
as.matrix(twitter.clean.tfidf[1:5,1:5])

# we've still got a very sparse document-term matrix. remove sparse terms at various thresholds.
tfidf.99 = removeSparseTerms(twitter.clean.tfidf, 0.99)# remove terms that are absent from at least 99% of documents (keep most terms)
tfidf.99

# we've still got a very sparse document-term matrix. remove sparse terms at various thresholds.
tfidf.98 = removeSparseTerms(twitter.clean.tfidf, 0.98)# remove terms that are absent from at least 99% of documents (keep most terms)
tfidf.98
matrix <- as.matrix(tfidf.98)
df.98 <- data.frame(matrix)
ncol(df.98)
df.97
#-------------------------------------------ATTEMPT----------------------------------------------------
df.98$car <- ifelse(df.98$car > 0, 1, 0) 
df.98$sentiment <- twitter$sentiment
df.98$futur <- ifelse(df.98$futur > 0, 1, 0)
df.98$googl <- ifelse(df.98$googl > 0, 1, 0)
df.98$legal <- ifelse(df.98$legal > 0, 1, 0)
df.98$like <- ifelse(df.98$like > 0, 1, 0)
df.98$new <- ifelse(df.98$new > 0, 1, 0)
df.98$use <- ifelse(df.98$use > 0, 1, 0)
df.98$will <- ifelse(df.98$will > 0, 1, 0)
df.98$cant <- ifelse(df.98$cant > 0, 1, 0)
df.98$can <- ifelse(df.98$can > 0, 1, 0)
df.98$less <- ifelse(df.98$less > 0, 1, 0)
df.98$new <- ifelse(df.98$new > 0, 1, 0)
df.98$see <- ifelse(df.98$see > 0, 1, 0)
df.98$want <- ifelse(df.98$want > 0, 1, 0)
df.98$work <- ifelse(df.98$work > 0, 1, 0)

linear_model <- lm(sentiment ~ car + futur + googl + legal + like + new + use + will + cant + can
          + less + new + see + want + work, data =df.98)
summary(linear_model)

lm.2 <- lm(sentiment ~ car + googl + use + cant + less + want, data =df.98)
summary(lm.2)

#----------------------TEST CLEANING
test_data <- read.csv("test.csv", header = TRUE)
test_c = VCorpus(DataframeSource(test_data))
#document.data.frame = as.data.frame(document.data.frame[,"c"], stringsAsFactors = FALSE)

inspect(test_c[1:2])
test_c[[1]]

# compute TF-IDF matrix and inspect sparsity
test.tfidf = DocumentTermMatrix(test_c, control = list(weighting = weightTfIdf))
test.tfidf  # non-/sparse entries indicates how many of the DTM cells are non-zero and zero, respectively.
# sparsity is number of non-zero cells divided by number of zero cells.

test.tfidf[1:5,1:5]
as.matrix(test.tfidf[1:5,1:5])

#document.data.frame = as.data.frame(test_c[,"c"], stringsAsFactors = FALSE)
# there's a lot in the documents that we don't care about. clean up the corpus.
removeURL <- function(x) gsub("http[^[:space:]]*", "", x)
test.clean = tm_map(test_c, content_transformer(removeURL))
removeAT <- function(x) gsub("@[^[:space:]]*", "", x)
test.clean = tm_map(test.clean, content_transformer(removeAT))
test.clean = tm_map(test.clean, stripWhitespace)                          # remove extra whitespace
#twitter.clean = tm_map(twitter.clean, removeNumbers)                      # remove numbers
test.clean = tm_map(test.clean, removePunctuation)                  # remove punctuation
test.clean = tm_map(test.clean, content_transformer(tolower))       # ignore case
test.clean = tm_map(test.clean, removeWords, stopwords("english"))  # remove stop words
test.clean = tm_map(test.clean, stemDocument)

test_c[[1]]
inspect(test_c[1:5])
head(test_data)
as.data.frame(test_data)
test_c[[1]]$content 

test.clean.tfidf = DocumentTermMatrix(test.clean, control = list(weighting = weightTfIdf))
test.98 = removeSparseTerms(test.clean.tfidf, 0.98)# remove terms that are absent from at least 99% of documents (keep most terms)
test.98
matrix <- as.matrix(test.98)
testdf.98 <- data.frame(matrix)
ncol(testdf.98)

testdf.98$car <- ifelse(testdf.98$car > 0, 1, 0) 
testdf.98$sentiment <- twitter$sentiment
testdf.98$futur <- ifelse(testdf.98$futur > 0, 1, 0)
testdf.98$googl <- ifelse(testdf.98$googl > 0, 1, 0)
testdf.98$legal <- ifelse(testdf.98$legal > 0, 1, 0)
testdf.98$like <- ifelse(testdf.98$like > 0, 1, 0)
testdf.98$new <- ifelse(testdf.98$new > 0, 1, 0)
testdf.98$use <- ifelse(testdf.98$use > 0, 1, 0)
testdf.98$will <- ifelse(testdf.98$will > 0, 1, 0)
testdf.98$cant <- ifelse(testdf.98$cant > 0, 1, 0)
testdf.98$can <- ifelse(testdf.98$can > 0, 1, 0)
testdf.98$less <- ifelse(testdf.98$less > 0, 1, 0)
testdf.98$new <- ifelse(testdf.98$new > 0, 1, 0)
testdf.98$see <- ifelse(testdf.98$see > 0, 1, 0)
testdf.98$want <- ifelse(testdf.98$want > 0, 1, 0)
testdf.98$work <- ifelse(testdf.98$work > 0, 1, 0)

testdf.98$sentiment = predict(linear_model, newdata = testdf.98, type = "response")
testdf.98$sentiment = floor(testdf.98$sentiment)

kaggle_submission = cbind(test_data$id, testdf.98$sentiment)
colnames(kaggle_submission) = c("Id", "SalePrice")
write.csv(kaggle_submission, file = "linear_model_adjusted2.csv", row.names = FALSE)


linear_model <- lm(sentiment ~ googl + use, data= df.97)
#------------------------------------ATTEMPT-------------------------------------------

as.matrix(tfidf.99[1:5,1:5])

tfidf.70 = removeSparseTerms(twitter.clean.tfidf, 0.70)  # remove terms that are absent from at least 70% of documents
tfidf.70
as.matrix(tfidf.70[1:2, 1:2])
twitter.clean[[1]]$content

# which documents are most similar?
dtm.tfidf.99 = as.matrix(tfidf.99)
dtm.dist.matrix = as.matrix(dist(dtm.tfidf.99))
most.similar.documents = order(dtm.dist.matrix[1,], decreasing = FALSE)
twitter_c[[most.similar.documents[1]]]$content
twitter_c[[most.similar.documents[2]]]$content
twitter_c[[most.similar.documents[3]]]$content
twitter_c[[most.similar.documents[4]]]$content
twitter_c[[most.similar.documents[5]]]$content

#---------------------RNG
sentiment <- c(sample(1:5, 979, replace = TRUE))
id <- c(seq(1:979))
prediction <- data.frame(id, sentiment)

#---------------------ALL 3's SUBMISSIONS
sentiment <- c(3)
id <- c(seq(1:979))
prediction <- data.frame(cbind(id, sentiment))

write.csv(prediction, file = "basic.csv", row.names = FALSE)