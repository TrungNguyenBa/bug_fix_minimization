multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
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
library(ggplot2)

for (y in unique(original_scores$ScoringScheme))  {
  for (i in unique(original_scores$Formula)) {
    mtemp <- minimized_scores[minimized_scores$ScoringScheme==y & minimized_scores$Formula==i,]
    mtemp$ver = "minimized"
    otemp <- original_scores[original_scores$ScoringScheme==y & original_scores$Formula==i,]
    otemp$ver = "original"
    ftemp <- rbind(mtemp,otemp)
   
    p <- ( ggplot() +geom_density(data=ftemp,alpha = 0.3,adjust=0.5,aes(x=Score,group=ver,colour=ver)) +
      scale_x_log10(limits=c(0.00001,1),breaks=c(0.0001,0.0001,0.001,0.01,0.1,1))) + ggtitle(i)
    ggsave(filename=(paste("/Users/trung/Documents/Umass_rs/bug_fix_minimization/plots/Fault_localization/",y,i,".png",sep="_")));
  }
  
  #multiplot(plotlist=b, cols=2)
  #ggsave(filename=(paste("/Users/trung/Documents/Umass_rs/bug_fix_minimization/plots/Fault_localization/",y,".png")));
}