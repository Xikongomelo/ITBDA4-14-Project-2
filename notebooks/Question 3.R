library(rvest)
library(dplyr)

#3.1
url <- "https://groundup.org.za/article/a-decade-of-wasted-consultancies-how-slovo-park-exposes-south-africas-informal-settlement-upgrade-failure/"

webpage <- read_html(url)

# Extract article details
title <- webpage %>%
  html_element("h1") %>%
  html_text2()

author <- "Marie Huchzermeyer"
date <- "5 May 2026"

#eextract article paragraphs
paragraphs <- webpage %>%
  html_elements("article p") %>%
  html_text2()

#Remove empty paragraphs
paragraphs <- paragraphs[paragraphs != ""]

#Create an R data frame
article_df <- data.frame(title = title, author = author,date = date,paragraph = paragraphs, stringsAsFactors = FALSE)

head(article_df)

#Check the number of paragraphs
nrow(article_df)

#Check the extracted text
head(article_df$paragraph, 5)

#Check the total number of characters
sum(nchar(article_df$paragraph))

#3.2
#start with the original paragraphs
article_clean$clean_text <- tolower(article_clean$paragraph)

#remove possessive apostrophe-s
article_clean$clean_text <- gsub("[’']s\\b", "", article_clean$clean_text)

#remove punctuation, numbers and special characters
article_clean$clean_text <- gsub("[^a-zA-Z\\s]", " ", article_clean$clean_text)

#remove extra whitespace
article_clean$clean_text <- gsub("\\s+", " ", article_clean$clean_text)
article_clean$clean_text <- trimws(article_clean$clean_text)

#remove stop words
article_clean$clean_text <- sapply(strsplit(article_clean$clean_text, "\\s+"),
  function(words) {paste(words[!words %in% stop_words], collapse = " ")}
)

head(article_clean$clean_text, 5)

sum(sapply(strsplit(article_clean$clean_text, "\\s+"),length))


#3.3
#Technique 1: Frequency-based extractive summarisation
#split  article into individual sentences
sentences <- unlist(strsplit(paste(article_df$paragraph, collapse = " "),"(?<=[.!?])\\s+", perl = TRUE))

#calculate word frequencies from the cleaned article
all_words <- unlist(strsplit(paste(article_clean$clean_text, collapse = " "), "\\s+"))

word_freq <- table(all_words)

#score each sentence using word frequencies
sentence_scores <- sapply(sentences, function(sentence) {
  
  sentence <- tolower(gsub("[^a-zA-Z\\s]", " ", sentence))
  words <- unlist(strsplit(sentence, "\\s+"))
  words <- words[words %in% names(word_freq)]
  
  if (length(words) == 0) {return(0)}
  
  mean(word_freq[words])
})

#select the five highest-scoring sentences
top_sentences <- data.frame(Sentence = sentences,Score = sentence_scores)
top_sentences <- top_sentences[order(top_sentences$Score, decreasing = TRUE), ]

head(top_sentences, 5)

#technique 2 : TF-IDF-based extractive summarisation

# Remove website footer and unrelated content
article_paragraphs <- article_df$paragraph

article_paragraphs <- article_paragraphs[
  !grepl(
    "support independent journalism|donate using|we respect your privacy|request permission to republish|email.*protected|this has still not been produced|this caused a breakdown in trust|next:|previous:|marie huchzermeyer is a professor",
    article_paragraphs,
    ignore.case = TRUE
  )
]

# Extract sentences from the article
sentences <- unlist(strsplit(paste(article_paragraphs, collapse = " "),"(?<=[.!?])\\s+",perl = TRUE))

# Tokenise sentences
sentence_words <- strsplit(tolower(gsub("[^a-zA-Z\\s]", " ", sentences)),"\\s+")

# Remove stopwords
sentence_words <- lapply(sentence_words, function(words) {
  words <- words[words != ""]
  words <- words[!words %in% stop_words]
  return(words)
})

# Calculate TF-IDF scores
tfidf_scores <- sapply(sentence_words, function(words) {
  
  if (length(words) == 0) {return(0)}
  
  tf <- table(words) / length(words)
  
  idf <- log(length(sentence_words) / (1 + sapply(names(tf), function(word) {
                 sum(sapply(sentence_words, function(x) word %in% x))})))
  sum(as.numeric(tf) * idf)
})

# Create and rank the summary
tfidf_summary <- data.frame(Sentence = sentences,Score = tfidf_scores)

tfidf_summary <- tfidf_summary[order(tfidf_summary$Score, decreasing = TRUE),]
rownames(tfidf_summary) <- NULL

# Display the five most important sentences
head(tfidf_summary, 5)


#visualisations

# Calculate word frequencies
all_words <- unlist(strsplit(paste(article_clean$clean_text, collapse = " "),"\\s+"))

word_freq <- sort(table(all_words), decreasing = TRUE)

# Create dataframe of the top 20 words
top_words <- head(data.frame(Word = names(word_freq),Frequency = as.numeric(word_freq)),20)

# Plot the most frequent words
library(ggplot2)

ggplot(top_words, aes(x = reorder(Word, Frequency), y = Frequency)) +geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Most Frequent Words in the Slovo Park Article",x = "Words",y = "Frequency") +theme_minimal()

#wordcloud
# Generate a word cloud
library(wordcloud)
library(RColorBrewer)

wordcloud(words = names(word_freq),freq = as.numeric(word_freq),max.words = 30,colors = brewer.pal(8, "Dark2"),
  scale = c(3, 1),
  random.order = FALSE
)