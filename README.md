# cricket_stats

## Aims
* Scrape data from stats.espncricinfo.com since the Australian summer of 1999.
* Develop new metrics and models for understanding performance.
* Assess the validity of current cricket metrics.

## Source
Data is currently sourced from:
* stats.espncricinfo.com

Always looking for more data sources!

## RProject
### V1.0
* Simple scrape of stats.espncricinfo.com with `rvest` package (https://github.com/hadley/rvest). Following API settings:  
```r
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
  ```
* Some cleaning applied to the scraping.

### Upcoming features
* Automated scraping: currently the number of pages needs to be set manually
* Data: other data from stats.espncricinfo.com
* Data cleaning: R scripts to clean data
* Analysis: some initial analysis tools
