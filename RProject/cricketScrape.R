## ESPN cricket stats html scrape

## Author:  Tom Schlosser
## Version: 1.0.1
## Date:    11 March 2015

## Description
#   This scrapes data from http://stats.espncricinfo.com/, saving the output as a csv.
#   The data scraped by default is all innings of batting since 1/12/2009.
#   ESPN does not expose all the data at once. Instead it splits the information into
#   pages. Therefore (well and I'm a little lazy), when using this script, you need 
#   to specify the number of pages you wish to pull. This involves opening the 
#   cricinfo_html in your browser and manually transcribing the total number of pages.

## Set-up ----

require(checkpoint)
#checkpoint("2015-03-01")

library(rvest)
library(stringr)
library(dplyr)

setwd("~/Repositories/cricketR/RProject")

## Global constants ----
# Calculate number of pages (this is a little inefficient - something to improve)
# Create html
cricinfo_html <- paste0(
  "http://stats.espncricinfo.com/ci/engine/stats/index.html?class=11;",
  "filter=advanced;",
  "orderby=runs;",
  "page=",1,";",
  "size=200;", 
  "spanmin1=01+Dec+1999;", 
  "spanval1=span;", 
  "template=results;", 
  "type=batting;",
  "view=innings"
)
# Scrape data from html table
cricpg <- html(cricinfo_html)

numberOfRecords <- cricpg %>% html_nodes(xpath="//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"left\", \" \" )) and (((count(preceding-sibling::*) + 1) = 2) and parent::*)] | //*[(((count(preceding-sibling::*) + 1) = 6) and parent::*)]//*[contains(concat( \" \", @class, \" \" ), concat( \" \", \"left\", \" \" ))]//*[(((count(preceding-sibling::*) + 1) = 6) and parent::*)]//b") %>% html_text()
numberOfRecords <- as.integer(str_trim(str_sub(numberOfRecords, 
                                               start = str_locate(numberOfRecords, " of ") + 4
                                               )
                                       )[1]
)

totl_pages = ceiling(numberOfRecords / 200)

## Initialise variables ----
a <- Sys.time()
pb <- txtProgressBar(min = 0, max = totl_pages, style = 3)
timings <- matrix(NA, nrow = totl_pages, ncol = 4)

cric <- data.frame(Player = as.character("string"), 
                   Runs = as.character("string"), 
                   Mins = 0, BF = 0, 
                   fours = 0, sixes = 0, SR = 0.00, 
                   Inns = 0, 
                   blank1 = 0,
                   Opp = as.character("string"), Ground = as.character("string"), 
                   Start.Date = as.Date("01 Jan 2001", "%d %b %Y"),
                   blank2 = 0,
                   pageNumber = 0
                   )

## Load and scrape html ----
for (i in 1:totl_pages) {
  # Timings
  timings[i, 1] = i
  timings[i, 2] = Sys.time()
  # Initialise progress bar
  Sys.sleep(0.1)
  setTxtProgressBar(pb, i)
  # Create html
  cricinfo_html <- paste0(
                          "http://stats.espncricinfo.com/ci/engine/stats/index.html?class=11;",
                          "filter=advanced;",
                          "orderby=runs;",
                          "page=",i,";",
                          "size=200;", 
                          "spanmin1=01+Dec+1999;", 
                          "spanval1=span;", 
                          "template=results;", 
                          "type=batting;",
                          "view=innings"
  )
  # Scrape data from html table
  cricpg <- html(cricinfo_html)
  data2 <- cricpg %>% html_nodes(xpath="//*/tbody/*/td") %>% html_text()
  data3 <- data.frame(matrix(data2, ncol = 13, byrow = TRUE))
  data3 <- data3 %>% mutate(pageNumber = i)
  data3 <- data3 %>% transmute(
    # Recode variable names and apply variable type
                               Player = as.character(X1),
                               Runs = as.character(X2),
                               Mins = ifelse(X3 == "-", NA, as.integer(X3)),
                               BF = ifelse(X4 == "-", NA, as.integer(X4)),
                               fours = ifelse(X5 == "-", NA, as.integer(X5)),
                               sixes = ifelse(X6 == "-", NA, as.integer(X6)),
                               SR = ifelse(X7 == "-", NA, as.double(X7)),
                               Inns = as.integer(X8),
                               blank1 = X9,
                               Opp = as.character(X10),
                               Ground = as.character(X11),
                               Start.Date = as.Date(X12, "%d %b %Y"),
                               blank2 = X13,
                               pageNumber = as.integer(pageNumber)
                               )
  cric <- merge(cric, data3, all = TRUE)
  # End timings
  timings[i, 3] = Sys.time()
  timings[i, 4] = timings[i, 3] - timings[i, 2]
}

## Quick clean ----
cric <- cric[2:dim(cric)[1], ]
cric <- cric %>% select(-blank1, -blank2)
# Calculate time taken & print
b <- Sys.time()
runTime <- b - a
runTime
numberOfRecords
totl_pages

## Output ----
write.csv(cric, 
          "cric_new.csv", 
          row.names = FALSE
          )

## Clear memory ----
close(pb)
rm(list = ls())
