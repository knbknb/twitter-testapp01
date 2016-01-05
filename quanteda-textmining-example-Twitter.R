# https://htmlpreview.github.io/?https://github.com/kbenoit/quanteda/blob/master/vignettes/quickstart.html#fn1
#
# Do something with the Twitter data stored as json files on disk (in a single zip file)
library(quanteda)
library(jsonlite)
library(dplyr)
options(stringsAsFactors = FALSE)

# example of a single data file
infile <- "~/Downloads/twusers/twitterusers.Tim_Martin.jaws3dfan.json"
#twusers_sample <- rjson::fromJSON(file=infile)
#tweets <- sapply(twusers_sample, function(x){x$status$text})

#twusers <- sapply(twusers_sample, function(x){x$screen_name})

zipfile <- "/data/sciencedata/twusers-2011.zip"

### contents of zipfile
# use external programs
#twfiles <- system(paste0("unzip -l ", zipfile, " | perl -anlE 'say $F[3]'"), intern = TRUE)

# use internal APIs
twfiles <- unzip(zipfile, list = TRUE)
from <- 1
to <- 1000
from:to
if(exists(twfilescontent)){
        rm(twfilescontent)
}

# each file contains an array of 20 twitter profiles, each with some tweets
# files content is  highly redundant, needs extensive pre- and postprocessing
twfilescontent <- lapply(twfiles[from:to, "Name"], function(x){
        #paste0(scan(unz(zipfile, filename = x, encoding = "UTF-8"), what = "character"), collapse = TRUE)
        #con = unz(zipfile, filename = x)
        #file(con, raw = TRUE, "r", encoding = "UTF-8")
        #on.exit(close(con))
        tmp <- try(expr={
                tmp2 <- readChar(unz(zipfile, filename = x, encoding = "UTF-8"), nchars = 1e+08)
                gsub(pattern="\n\\]\n?\\[\n?", replacement = '\n],[', x = tmp2, perl = TRUE)
                }, silent = TRUE)

        paste0("[", tmp, "]", collapse = "")
        #tmp
})


# remove empty list elements (comma substitution was unsuccessful)
filter1 <- function(li){
        li[unlist(lapply(li, function(x){length(x[1]) > 0}))]
}

# parse string to json, silently skip all where JSON parse did fail
twfileslist <- filter1(lapply(twfilescontent, function(x){
        res <- try(expr={fromJSON(x)}, silent = TRUE)
        if(class(res) != "try-error"){res}
}))
twfilescontent <- paste0("was ", length(twfilescontent))

# explore before preprocessing
simpletypes <- c("character", "logical", "integer")
last <- length(twfileslist)
j <- twfileslist[[last]]
length(j)
one_search <- j[[1]]
colnames(one_search)
coltypes <- sapply(one_search, typeof)
setdiff(coltypes, colnames(one_search[, coltypes %in% simpletypes]))

which( colnames(one_search) == "status")
colnames(one_search[coltypes %in% simpletypes]) == "status"

length(one_search$status)
one_search$id

# get the tweets status (contain text of tweet), append user id
twstatus <-lapply(twfileslist, function(file){try({unique(do.call(dplyr::bind_rows,
             lapply(file, function(x){
                     x$status$retweeted_status <- NULL
                     x$status$contributors <- NULL
                     x$status$place <- NULL
                     coltypes2 <- sapply(x$status, typeof)
                     good_colnames2 <- colnames(x$status[, coltypes2 %in% simpletypes])
                     #x[good_colnames]
                     cbind("id"=as.character(x$id), x$status[, good_colnames2])
                     #list("tweet"=y, "status"=x$status[, good_colnames2])
             })
))}, silent=TRUE)})

#twstatus1 <- twstatus[1]
# get twitter user metadata
twprofiles <-lapply(twfileslist, function(file){unique(do.call(dplyr::bind_rows,
             lapply(file, function(x){
                     x$status <- NULL
                     x$entities <- NULL
#                     coltypes <- sapply(one_search, typeof)
#                     good_colnames <- colnames(one_search[, coltypes %in% simpletypes])
                     x
             })
))})

# more preprocessing
twstatus2 <- do.call(dplyr::bind_rows,
                  lapply(twstatus, function(x){
                          if(is.data.frame(x)){
                          if("retweet_count" %in% names(x)) {
                                  x$retweet_count <- as.character(x$retweet_count)
                          }
                          x}
                  }))

twprofiles2 <-do.call(dplyr::bind_rows,
                     lapply(twprofiles, function(x){
                             x
                     }))

# join + remove redundant rows
twprofiles_tweets <- unique( twprofiles2 %>% inner_join(twstatus2, by="id"))
if(exists("twfileslist")){
        rm(twfileslist)
        rm(twprofiles2)
        rm(twstatus2)
}
#####  preprocessing end, begin text mining (simple exploratory)

myCorpusTwitter <- corpus(twprofiles_tweets$text, docvars=data.frame(screenname=twprofiles_tweets$screen_name, name=twprofiles_tweets$name),
                          notes="Tweets from 2011",
                          enc="UTF-8")
summ <- as.data.frame(summary(myCorpusTwitter, 500))
summ[order(summ$name),]
# create a dfm, removing stopwords
mydfm <- dfm(myCorpusTwitter, ignoredFeatures=c(stopwords("english")))


# twitter accounts mentioned
sort(grep("^@", features(mydfm), perl=TRUE, value = TRUE))

n <- 200
topn <- topfeatures(mydfm, n)
topn[which(nchar(names(topn)) > 5)]
# kwic(myCorpusTwitter, names(topn[1]), 3)


max(twprofiles_tweets$retweet_count, na.rm = TRUE)

plot(mydfm, min.freq = 6, random.order = FALSE)

icdp <- grep("icdp", twprofiles_tweets$text, value = TRUE)

sample(twprofiles_tweets$text, 20)

