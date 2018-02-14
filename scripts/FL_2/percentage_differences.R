library("base")
library("reshape")
workingdir <- Sys.getenv("BFM_DATA")
if (workingdir == "") {
  stop ("BFM_DATA is not set")
}
print(workingdir[1])
setwd(workingdir)
getwd()

source("statiscal_analysis_scripts/Object_Creating.R")

diff_first <- abs( (minimized_scores[minimized_scores$ScoringScheme == "first",]$Score - original_scores[original_scores$ScoringScheme == "first",]$Score )/minimized_scores[minimized_scores$ScoringScheme == "first",]$Score*100 )
diff_median <- abs( (minimized_scores[minimized_scores$ScoringScheme == "median",]$Score - original_scores[original_scores$ScoringScheme == "median",]$Score )/minimized_scores[minimized_scores$ScoringScheme == "median",]$Score*100 )
diff_last <- abs( (minimized_scores[minimized_scores$ScoringScheme == "last",]$Score - original_scores[original_scores$ScoringScheme == "last",]$Score )/minimized_scores[minimized_scores$ScoringScheme == "last",]$Score*100 )
min <- min(diff_first[diff_first > 0.0],diff_last[diff_last > 0.0],diff_median[diff_median > 0.0]) 
max <- max(diff_first[diff_first > 0.0],diff_last[diff_last > 0.0],diff_median[diff_median > 0.0])
diff_first[diff_first == 0] <- min/32
diff_last[diff_last == 0] <- min/32
diff_median[diff_median == 0] <- min/32


len <- length(diff_first)
#data_table <- data.frame(FirstScore = diff_first[c(len/4,len/2,len*3/4),],MedianSore = (diff_median[c(len/4,len/2,len*3/4),]),LastScore = (diff_last[c(len/4,len/2,len*3/4),]))
data_plot <- data.frame(Best = log2(diff_first),Median= log2(diff_median),Worst = log2(diff_last))

boxplot(log2(diff_first))
library(ggplot2) 
ggplot(data=melt(data_plot,measure.vars=c("Best","Median","Worst")), aes(x = variable, y = value)) + geom_boxplot()+ ylab("Percent Difference\n(log 2 scale)") +  xlab ("Debugging Scenario") + 
theme_bw() + theme(legend.position="none",axis.title.y  = element_text(size = 10)) + scale_fill_grey(start = 0.4, end = .9) 
ggsave(filename=("statiscal_analysis_scripts/FL_analysis/Bug-to-bug_Percent_Difference.pdf"))
