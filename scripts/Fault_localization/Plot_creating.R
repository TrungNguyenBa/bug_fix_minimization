  
library(ggplot2)
library(ggpubr)

for (y in unique(original_scores$ScoringScheme))  {
  list_plot <- c()
  index <- 1
  for (i in unique(original_scores$Formula)) {
    mtemp <- minimized_scores[minimized_scores$ScoringScheme==y & minimized_scores$Formula==i,]
    mtemp$ver = "minimized"
    otemp <- original_scores[original_scores$ScoringScheme==y & original_scores$Formula==i,]
    otemp$ver = "original"
    ftemp <- rbind(mtemp,otemp)
   
    p <- ( ggplot() +geom_density(data=ftemp,alpha = 0.3,adjust=0.5,aes(x=Score,group=ver,colour=ver)) +
      scale_x_log10(limits=c(0.00001,1),breaks=c(0.0001,0.0001,0.001,0.01,0.1,1))) + ggtitle(i)
    ggsave(filename=(paste("/Users/trung/Documents/Umass_rs/bug_fix_minimization/plots/Fault_localization/",y,i,".png",sep="_")));
    #list_plot[[index]] <- p
    #index <- index +1
  }
  #multiplot(plotlist=b, cols=2)
  #ggarrange(plotlist =  list)
  #print(length(list_plot))
  #ggsave(filename=(paste("/Users/trung/Documents/Umass_rs/bug_fix_minimization/plots/Fault_localization/",y,".png")));
}

