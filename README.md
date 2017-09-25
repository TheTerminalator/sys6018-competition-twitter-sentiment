# sys6018-competition-twitter-sentiment

**Parametric Model**: parametric_model.R

**KNN from scratch**: KNN_Nonparametric.R

## Roles:

* **Tyler**: Data cleaning/exploration and alternative models.
* **Sally**: Implement parametric model and LOOCV for that model.
* **Isabelle**: Implement KNN from scratch and cross validation for that model.

## Reflection:

### Who might care about this problem and why?

Google and other companies/entities interested in developing self-driving cars may be interested in public perceptions surrounding self-driving vehicles. This knowledge could be used to make marketing-related decisions. For instance, if the average person thinks that self-driving cars are dangerous, Google can try to take steps to assure the public that self-driving cars are, in fact, safer than traditional cars.

### Why might this problem be challenging?

With a training set that only consisted of 981 tweets, we felt that we did not have enough data to build a successful model. We had to deal with a frustratingly sparse document-term matrix, and ultimately found that we achieved higher predictive success (according to LOOCV) when we reduced the document-term matrix to a handful of variables, causing our parametric regression models to predict the mode (3) for almost all inputs. With such a small number of variables, the document-term matrix did not contain any sentiment-related words, defeating the point of “sentiment analysis.”

In light of this experience, we concluded that text mining problems require large dataset (i.e. millions of tweets, rather than <1k). Part of why such a large dataset is needed is that, due to the nature of human language, one sentiment can be expressed in a myriad of different ways. With a dataset as small as the one we had, it is almost impossible to find any meaningful commonalities between documents that share the same sentiment rating.

### What other problems resemble this problem?

—
