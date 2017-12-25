
minimized_scores<-read.csv("/Users/trung/Documents/Umass_rs/FL_techniques/fault-localization-data/analysis/pipeline-scripts/Scores/minimized/master_scores.csv")
original_scores<-read.csv("/Users/trung/Documents/Umass_rs/FL_techniques/fault-localization-data/analysis/pipeline-scripts/Scores/original/master_scores.csv")

minimized_scores <- unique(minimized_scores)
original_scores <- unique(original_scores)
if (length(original_scores) == length(minimized_scores)) {
  for (fol in unique(minimized_scores$Formula)) {
    ms <- minimized_scores[minimized_scores$Formula == fol,]
    os <- original_scores[original_scores$Formula == fol,]
    score_diff_ab_percent <- (( abs(os$Score - ms$Score))/ms$Score*100)
    print (fol)
    print(mean(score_diff_ab_percent))
    print(median(score_diff_ab_percent))
    print ( (length(score_diff_ab_percent[ score_diff_ab_percent > 15 ])) /(length(score_diff_ab_percent)))
    print ( (length(score_diff_ab_percent[ score_diff_ab_percent > 50 ])) /(length(score_diff_ab_percent)))
    print ( (length(score_diff_ab_percent[ score_diff_ab_percent > 100 ])) /(length(score_diff_ab_percent)))
    print ("end")
    print ("")
  }

}