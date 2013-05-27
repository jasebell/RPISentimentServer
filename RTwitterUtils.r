library(twitteR)
library(stringr)
library(RSQLite)
library(plyr)

TweetFrame<-function(searchTerm, maxTweets) {
  load("credentials.RData")
  registerTwitterOAuth(cred)
  tweetList<-searchTwitter(searchTerm,n=maxTweets)
  tweetDF<-do.call("rbind", lapply(tweetList, as.data.frame))
  return(tweetDF[order(as.integer(tweetDF$created)), ])
}

CleanTweets<-function(tweets){
  tweets <- str_replace_all(tweets,"  ", " ")
  tweets <- str_replace_all(tweets,"http://t.co/[a-z,A-Z,0-9]{8}","")
  tweets <- str_replace_all(tweets,"RT [a-z,A-Z]*: ","")
  tweets <- str_replace_all(tweets,"#[a-z,A-Z0-9]*","")
  tweets <- str_replace_all(tweets,"@[a-z,A-Z0-9]*","")
  return(tweets)
}

SaveTweetToDB<-function(dbconn, tweetid, tweetuser, tweetdata, sentimentscore) {
  dbBeginTransaction(dbconn)
  tweetTextEdit<-iconv(tweetdata, to="UTF-8", sub='byte')
  sql<-paste("insert into twitterdata (twitterid, twitteruser, twitterdata,sentimentscore) values ('", tweetid,"','",tweetuser,"','",tweetTextEdit,"',",sentimentscore,")")
  print(sql)
  tryCatch(dbSendQuery(dbconn, sql), error=function(e) { print("caught error on insert")})
  dbCommit(dbconn)
}

GetConnection<-function(){
  db <- dbConnect(dbDriver("SQLite"), dbname="twitter.db")
  return(db)
}

CloseConnection<-function(db){
  dbDisconnect(db)
}

LoadPosWordSet<-function(){
  iu.pos = scan("positive-words.txt", what='character', comment.char=";")
  pos.words = c(iu.pos)
  return(pos.words)
}

LoadNegWordSet<-function(){
  iu.neg = scan("negative-words.txt", what='character', comment.char=";")
  neg.words = c(iu.neg)
  return(neg.words)
}

GetScore<-function(sentence, pos.words, neg.words) {
  sentence = gsub('[[:punct:]]', '', sentence)
  sentence = gsub('[[:cntrl:]]', '', sentence)
  sentence = gsub('\\d+', '', sentence)
  # and convert to lower case:
  sentence = tolower(sentence)
  
  word.list = str_split(sentence, '\\s+')
  words = unlist(word.list)
  
  pos.matches = match(words, pos.words)
  neg.matches = match(words, neg.words)
  
  pos.matches = !is.na(pos.matches)
  neg.matches = !is.na(neg.matches)
  score = sum(pos.matches) - sum(neg.matches)
  
  return(score)
}
