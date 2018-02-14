source("Object_Creating.R")
get_id_as_range <- function(data) {
    ranges<- character()
    min <- min(data$Bug)
    max <- max(data$Bug)
    missing <- setdiff(min:max,data$Bug)
    if (length(missing) == 0) {
      return(paste(min,max,sep="-"))
    }
    print(missing)
    mark <- 0
    for (i in 1:length(missing)) {
      if (i == 1) {
        if (missing[i] -1 > min) {
          ranges [[length(ranges)+1]] <- paste(min,"-",missing[i]-1,sep ="")
        }
        else {
          ranges [[length(ranges)+1]] <- toString(min)
        }
      }
      else {
        if (missing[i-1]+1 < missing[i]) {
          if (missing[i-1] +1 <  missing[i]-1) {
            ranges[[length(ranges)+1]]  <- paste(missing[i-1]+1 ,"-",missing[i]-1, sep = "")
          }
          else {
            ranges[[length(ranges)+1]] <- toString(missing[i-1]+1)
          }
        }
      }
      if ( i == length(missing)) {
        if (missing[i] +1 < max) {
          ranges [[length(ranges)+1]] <- paste(missing[i]+1,"-",max, sep = "")
        }
        else {
          ranges [[length(ranges)+1]] <- toString(max)
        }
      }
      

    }
    print(ranges)
    return (paste(ranges,collapse = ', '))
}

minimized_bugs <- merge (unique(minimized_scores[,c("Project","Bug")]),unique(minimized_version[,c("PID","BID")]), by.x = c("Project","Bug"),by.y=c("PID","BID"))
non_minimized_bugs <- merge (unique(original_scores[,c("Project","Bug")]),unique(non_minimized_version[,c("PID","BID")]), by.x = c("Project","Bug"),by.y=c("PID","BID"))

minimized_bugs$Bug_non <- minimized_bugs$Bug*100000
total_bugs <- merge(minimized_bugs,non_minimized_bugs,by.x = c("Project","Bug_non"), by.y = c("Project","Bug"))

total_bugs[order(total_bugs$Project,total_bugs$Bug),]
tabledata <- data.frame(Project=character(),Total_Bugs=integer(),Bug_ids=character(),stringsAsFactors=FALSE)
get_id_as_range(total_bugs[total_bugs$Project == "Lang",])
for (p in unique(total_bugs$Project)) {
  tb <- nrow(total_bugs[total_bugs$Project == p, ])
  ids <- get_id_as_range(total_bugs[total_bugs$Project == p, ])
  tabledata[nrow(tabledata)+1,] <- c(p,tb,ids)
}
library(xtable)
print(xtable(tabledata,type = "latex"),file="statiscal_analysis_scripts/Defect_Sumary.tex")
