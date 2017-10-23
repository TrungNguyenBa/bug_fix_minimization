commit_changes_files <- data.frame(PID=character(),BID=integer(),nfcm=integer(),nfcunm=integer(),nf_diff=integer())
for (p in unique(commit_changes$PID)) {
  nw <- all_diff[all_diff$PID == p,]
  print (p)
  for (b in unique(nw$BID )) {
    t <- nrow(nw[nw$BID == b,])
    tu <- nrow(all_diff_or[all_diff_or$PID == p & all_diff_or$BID == b,])
    if (tu >0) {
      commit_changes_files$PID <- as.character(commit_changes_files$PID)
      commit_changes_files[nrow(commit_changes_files)+1,] = c(toString(p),b,t,tu,tu-t)  
      commit_changes_files$PID <- as.factor(commit_changes_files$PID)
    }
    
  }
}