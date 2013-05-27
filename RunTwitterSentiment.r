source("RTwitterUtils.r")
args<-commandArgs(trailingOnly=TRUE)

RunTwitterSentiment<-function(searchterm, qty){
  print(paste("Searching for: ",searchterm))
  pos.words = LoadPosWordSet()
  neg.words = LoadNegWordSet()
  
  tweets<-TweetFrame(searchterm, qty)
  
  db<-GetConnection()
  
  by(tweets, 1:nrow(tweets), function(row){ 
    print(row$text)
    tweetScore = 0
    sentimentOkay = TRUE
      tryCatch(
               tweetScore<-GetScore(row$text, pos.words, neg.words)
               , error=function(e) {
        sentimentOkay = FALSE
      })
      
      if(sentimentOkay) {
        SaveTweetToDB(db, row$id, row$screenName, row$text, tweetScore)
      }
      
    }
  )
  
  CloseConnection(db)
}

RunTwitterSentiment(args[1], args[2])

