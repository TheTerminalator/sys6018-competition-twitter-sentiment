# SYS 6018: Competition 3
# Xinyang Liu, Sally Gao, Tyler Lewris

library(tm)

# Read in training dataset 
tweets.df <- read.csv("train.csv")
# Read in testing dataset, remove column "id", and create a new column "sentiment" with value NA
tweets.test.df <- read.csv("test.csv")
tweets.test <- subset(tweets.test.df, select = -id)
tweets.test$sentiment <- NA
# Combine two dataframe, leave only the content
tweets.comb.df <- rbind(tweets.df, tweets.test)
tweets.comb <- as.data.frame(tweets.comb.df[, "text"], stringAsFactors = FALSE)
# Convert this part of the data frame to a corpus object.
tweets.comb <- VCorpus(DataframeSource(tweets.comb))

# there's a lot in the documents that we don't care about. clean up the corpus.
tweets.clean = tm_map(tweets.comb, stripWhitespace)                          # remove extra whitespace
tweets.clean = tm_map(tweets.clean, removeNumbers)                      # remove numbers
tweets.clean = tm_map(tweets.clean, removePunctuation)                  # remove punctuation
tweets.clean = tm_map(tweets.clean, content_transformer(tolower))       # ignore case
tweets.clean = tm_map(tweets.clean, removeWords, stopwords("english"))  # remove stop words
tweets.clean = tm_map(tweets.clean, stemDocument)                       # stem all words
tweets.clean <- tm_map(tweets.clean, PlainTextDocument)                 # treat preprocessed documents as text documents

# compute TF-IDF matrix
tweets.clean.tfidf = DocumentTermMatrix(tweets.clean, control = list(weighting = weightTfIdf))
tweets.clean.tfidf

# we've still got a very sparse document-term matrix. remove sparse terms at various thresholds.
tfidf.99 = removeSparseTerms(tweets.clean.tfidf, 0.99)  # remove terms that are absent from at least 99% of documents (keep most terms)
tfidf.99

# Convert the document-term matrix to a dataframe
df.tfidf.99 = as.data.frame(as.matrix(tfidf.99))
df.tfidf.99 = cbind(tweets.comb.df$sentiment, df.tfidf.99)
colnames(df.tfidf.99)[1] <- "sentiment"
# Create a dataframe of distances between variables
df.dist.matrix = as.matrix(dist(df.tfidf.99))

# Cross Validation of KNN
# Split data by rownumber into two equal portions
train <- sample(nrow(df.tfidf.99[1:981,]), ceiling(nrow(df.tfidf.99[1:981,]) * .50))
test <- (1:nrow(df.tfidf.99[1:981,]))[- train]
# Isolate classifier
cl <- df.tfidf.99[1:981, "sentiment"]
# Create model data and remove "category"
modeldata <- df.tfidf.99[1:981,!colnames(df.tfidf.99[1:981,]) %in% "sentiment"]
# Create model: training set, test set, training set classifier
knn.pred1 <- knn(modeldata[train, ], modeldata[test, ], cl[train], k = 1)
knn.pred2 <- knn(modeldata[train, ], modeldata[test, ], cl[train], k = 3)
knn.pred3 <- knn(modeldata[train, ], modeldata[test, ], cl[train], k = 5)
knn.pred4 <- knn(modeldata[train, ], modeldata[test, ], cl[train], k = 10)
# Confusion matrix
conf.mat1 <- table("Predictions" = knn.pred1, Actual = cl[test])
conf.mat2 <- table("Predictions" = knn.pred2, Actual = cl[test])
conf.mat3 <- table("Predictions" = knn.pred3, Actual = cl[test])
conf.mat4 <- table("Predictions" = knn.pred4, Actual = cl[test])
# Accuracy
(accuracy <- sum(diag(conf.mat1))/length(test) * 100) # 48.77551
(accuracy <- sum(diag(conf.mat2))/length(test) * 100) # 52.85714
(accuracy <- sum(diag(conf.mat3))/length(test) * 100) # 60.20408
(accuracy <- sum(diag(conf.mat4))/length(test) * 100) # 60.40816
#-----------------RATIONALE FOR K IN KNN MODEL----------------------
#After careful analysis and several different k values, it is clear that
#k=5 gives a pretty good result compared to k=1 and k=3
# and increasing k from 5 does not increase accuracy much
#Therefore, we will be using K=5 in our non-parametric model as it is clearly the value that
#gives us the best result when compared to other smaller or larger k values.

# knn from scratch
# Create a dataframe to store k nearest index for each tweet
knn_idx <- data.frame()
for (i in 982:1960){
  knn_idx <- rbind(knn_idx, sort(df.dist.matrix[1:981, i], index.return = TRUE)$ix[1:5])
}
# Find the corresponding sentiment value for each index
for (i in 1:979){
  for (j in 1:5){
    knn_idx[i, j] <- tweets.comb.df[knn_idx[i, j],]$sentiment
  }
}
knn_stmt <- c()
for (i in 1:979){
  # Find the most frequent sentiment for each tweet, and store it in a vector
  knn_stmt <- c(knn_stmt, names(sort(summary(as.factor(unname(unlist(knn_idx[i,])))), decreasing=T)[1]))
}
knn_stmt <- data.frame(knn_stmt)
knn_stmt <- cbind(tweets.test.df$id, knn_stmt)
write.table(knn_stmt, file="preds_knn.csv", row.names=F, col.names=c("id", "sentiment"), sep=",")
