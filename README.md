# sys6018-competition-twitter-sentiment

**Parametric Model**: parametric_model.R

*Parametric Model Score*: Best Kaggle Submission Score: 0.67893

**KNN from scratch**: KNN_Nonparametric.R
*Non Parametric Model Score*: Best Kaggle Submission Score: 0.59713

## Roles:

* **Tyler**: Data cleaning/exploration and alternative models.
* **Sally**: Implement parametric model and LOOCV for that model.
* **Isabelle**: Implement KNN from scratch and cross validation for that model.

## Reflection:

### Who might care about this problem and why?

Google and other companies/entities interested in developing self-driving cars may be interested in public perceptions surrounding self-driving vehicles. This knowledge could be used to make marketing-related decisions. For instance, if the average person thinks that self-driving cars are dangerous, Google can try to take steps to assure the public that self-driving cars are, in fact, safer than traditional cars. 

At the individual level, this particular problem could be of interest to those commuting in densly populated cities where public transportation is readily available and well established. Perhaps the individual is weighing the cost/benefit of commuting via self-driving car versus other forms of public transportation and seeks to gain insight from other people's perspective. Grasping a public consensus could be beneficial and reassuring.

### Why might this problem be challenging?

With a training set that only consisted of 981 tweets, we felt that we did not have enough data to build a successful model. We had to deal with a frustratingly sparse document-term matrix, and ultimately found that we achieved higher predictive success (according to LOOCV) when we reduced the document-term matrix to a handful of variables, causing our parametric regression models to predict the mode (3) for almost all inputs. With such a small number of variables, the document-term matrix did not contain any sentiment-related words, defeating the point of “sentiment analysis.”

In light of this experience, we concluded that text mining problems require large dataset (i.e. millions of tweets, rather than <1k). Part of why such a large dataset is needed is that, due to the nature of human language, one sentiment can be expressed in a myriad of different ways. With a dataset as small as the one we had, it is almost impossible to find any meaningful commonalities between documents that share the same sentiment rating.

### What other problems resemble this problem?

The applications of this particular problem translate well to other fields and industries. Companies/entities interested in analyzing textual information (tweets) to discern a subjective outcome (sentiment) can be applied towards a broad spectrum of situations. Understanding public opinion of a new brand, determining whether or not people think favorably of a new software update, determining which neighborhoods are most likely to commit a crime, and political candidate favorability are all legitimate "problems" that resemble self-driving car sentiment analysis. 

It is fascinating to think of the future potential applications of problems similar to this. With a powerful model and some form of sentiment tied data, one could gather a great deal of intel about public opinion. To speak specifically in terms of marketing, corporations could use models, like the ones we created, to harness a better understanding of consumer sentiment on a larger population than ones other than sample-limited studies - such as focus groups or surveys. In turn, this could reduce marketing costs, improve actual products, and overall provide a better experience to both the consumer and the corporation.
