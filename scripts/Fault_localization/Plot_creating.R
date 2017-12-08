minimized_scores<-read.csv("/Users/trung/Documents/Umass_rs/FL_techniques/fault-localization-data/analysis/pipeline-scripts/Scores/minimized/master_scores.csv")
original_scores<-read.csv("/Users/trung/Documents/Umass_rs/FL_techniques/fault-localization-data/analysis/pipeline-scripts/Scores/original/master_scores.csv")
minimized_scores <- unique(minimized_scores)
original_scores <- unique(original_scores)

if (nrow(minimized_scores) != nrow(original_scores)) {
  print("lengths of two data frames are not the same")
  quit 
}
original_scores<-original_scores[with(original_scores,order(original_scores$Score)),]
minimized_scores<-minimized_scores[with(minimized_scores,order(minimized_scores$Score)),]

mtemp <- minimized_scores[minimized_scores$ScoringScheme=="first" & minimized_scores$TotalDefn=="tests",]
otemp <- original_scores[original_scores$ScoringScheme=="first" & original_scores$TotalDefn=="tests",]

library(ggplot2)
ggplot2(mtemp,aes(x=Score)) + geom_density()