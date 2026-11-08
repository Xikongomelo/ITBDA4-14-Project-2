library(stringr)
library(stopwords)

news_files <- list.files(path = "sa_news",pattern = "^news_[0-9]+\\.txt$",full.names = TRUE)

length(news_files)

#2.1
filetext_prep <- function(file_name) {
  
  text <- tolower(paste(readLines(file_name, warn = FALSE), collapse = " "))
  text <- gsub("[^a-zA-Z\\s]", " ", text)
  text <- gsub("\\s+", " ", text)
  words <- unlist(strsplit(trimws(text), "\\s+"))
  words <- words[!words %in% stopwords::stopwords("en")]
  
  paste(words, collapse = " ")
}

news_df <- data.frame(col_1 = basename(news_files),col_2 = sapply(news_files, filetext_prep),
  stringsAsFactors = FALSE)

head(news_df)

data.frame(file = news_df$col_1,words = sapply(strsplit(news_df$col_2, "\\s+"), length),characters = nchar(news_df$col_2))

#2.2
#creating the document-term matrix
library(tm)
library(topicmodels)

corpus <- Corpus(VectorSource(news_df$col_2))
dtm <- DocumentTermMatrix(corpus)
inspect(dtm)


#applying LDA
lda_model <- LDA(dtm, k = 5, control = list(seed = 2026))

#top 15 words:
top_words <- terms(lda_model, 15)
top_words

#the words distributions
topic_probabilities <- as.data.frame(posterior(lda_model)$terms)

topic_dfs <- list()

for (i in 1:5) {
  
  topic_df <- data.frame(term = top_words[, i],probability = as.numeric(topic_probabilities[i, top_words[, i]]))
  
  topic_df <- topic_df[order(topic_df$probability, decreasing = TRUE), ]

  topic_dfs[[paste("Topic", i)]] <- topic_df}

topic_dfs

#2.3
library(wordcloud)
library(RColorBrewer)
library(ggplot2)

set.seed(2026)

for (i in 1:5) {
  
  topic <- topic_dfs[[i]]
  wordcloud( words = topic$term,freq = topic$probability,min.freq = 1,max.words = 15,random.order = FALSE,colors = brewer.pal(8, "Dark2"))
  title(paste("Word Cloud for Topic", i))
}

for (i in 1:5) {
  
  topic <- topic_dfs[[i]]
  
  p <- ggplot(topic, aes(x = reorder(term, probability), y = probability)) +
    geom_bar(stat = "identity", fill = "blue") +
    coord_flip() +
    labs(title = paste("Top Terms in Topic", i),x = "Term",y = "Probability") +theme_minimal()
  
  print(p)
}