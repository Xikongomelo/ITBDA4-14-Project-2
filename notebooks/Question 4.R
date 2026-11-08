# Load required libraries
library(rvest)
library(xml2)

# Read the two SAnews archive pages
page1 <- read_html("https://www.sanews.gov.za/south-africa")
page2 <- read_html("https://www.sanews.gov.za/south-africa?page=1")

# Extract article links from both pages
links1 <- page1 %>%
  html_elements("h2 a") %>%
  html_attr("href")

links2 <- page2 %>%
  html_elements("h2 a") %>%
  html_attr("href")

# Combine links and remove duplicates
article_urls <- unique(c(links1, links2))

# Convert links to complete URLs
article_urls <- url_absolute(article_urls, "https://www.sanews.gov.za")

# Create a data frame
article_data <- data.frame(article_url = article_urls,stringsAsFactors = FALSE)

# Extract the text from each article
get_text <- function(url) {
  page <- read_html(url)
  
  text <- page %>%
    html_elements("p") %>%
    html_text2() %>%
    paste(collapse = " ")
  
  return(text)
}

article_data$article_text <- sapply(article_data$article_url,get_text)

# Calculate the length of each article
article_data$article_length <- nchar(article_data$article_text)

# Use regular expressions to extract percentages
article_data$percentages <- lapply(
  article_data$article_text,
  function(x) {
    regmatches(x, gregexpr("[0-9]+%", x))[[1]]
  }
)

# Count the percentages found in each article
article_data$percentage_count <- lengths(article_data$percentages)

# Display the extracted data
head(article_data)
View(article_data)

# Check the number of articles collected
nrow(article_data)

# Check article text lengths
summary(article_data$article_length)

# Check the number of percentages extracted
summary(article_data$percentage_count)

# Check for missing and empty article text
sum(is.na(article_data$article_text))
sum(trimws(article_data$article_text) == "")

# Identify repeated spaces using regular expressions
spacing_issues <- sapply(article_data$article_text, function(x) {
  matches <- gregexpr(" {2,}", x)[[1]]
  if (matches[1] == -1) 0 else length(matches)
})

# Count articles containing repeated spaces
sum(spacing_issues > 0)

# Count repeated-space occurrences
sum(spacing_issues)

nrow(article_data)
length(unique(article_data$article_url))


#4.2
colSums(is.na(article_data))
#replacing repeated wwhitespace
article_data$article_text <- gsub("\\s+"," ",article_data$article_text)
article_data$article_text <- trimws(article_data$article_text)

#Recalculating article lengths.
spacing_issues <- sapply(article_data$article_text, function(x) {
  matches <- gregexpr(" {2,}", x)[[1]]
  if (matches[1] == -1) 0 else length(matches)
})

sum(spacing_issues)


article_data$article_length <- nchar(article_data$article_text)

head(article_data)
summary(article_data$article_length)


#export cleaned csv
article_data$percentages <- sapply(article_data$percentages, paste, collapse = ", ")
article_data$percentages[article_data$percentage_count == 0] <- "None"



head(article_data$percentages, 10)
sum(article_data$percentages == "None", na.rm = TRUE)

write.csv(article_data, "sanews_cleaned.csv", row.names = FALSE)
check <- read.csv("sanews_cleaned.csv")
sum(check$percentages == "None", na.rm = TRUE)