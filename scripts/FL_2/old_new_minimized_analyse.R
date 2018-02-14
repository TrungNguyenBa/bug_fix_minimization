library(ggplot2)
row.names(minimized_scores) <- 1:nrow(minimized_scores)
row.names(old_scores) <- 1:nrow(old_scores)
diff_row <- abs((minimized_scores$Score - old_scores$Score)/old_scores$Score*100)
significant_diff <- which(diff_row > 0)

blacklist_row <- minimized_scores[significant_diff,]
row.names(blacklist_row) <- 1:nrow(blacklist_row)
blacklist <- (unique(blacklist_row[,c("Project","Bug","Formula")]))
row.names(blacklist) <- 1:nrow(blacklist)
black_list_by_formula <- c()
for (f in unique(blacklist[,c("Formula")])) {
  print(f)
  black_list_by_formula <- c(black_list_by_formula,nrow(blacklist[blacklist$Formula == f,]))
}

black_list_by_PB <-unique(blacklist[,c("Project","Bug")])

