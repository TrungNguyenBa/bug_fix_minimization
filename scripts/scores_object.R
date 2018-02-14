master_scores<-read.csv("master_scores.csv")
original_scores<-master_scores[master_scores$Bug >= 100000 & master_scores$TotalDefn == "tests",]

minimized_scores<- master_scores[master_scores$Bug < 100000 & master_scores$TotalDefn == "tests",]
remove_array <- integer()
for (i in 1:nrow(minimized_scores)) {
  bugid = (minimized_scores [i,]$Bug)[1]*100000
  project= (minimized_scores [i,]$Project)[1]
  fomular= (minimized_scores [i,]$Formula)[1]
  if (nrow(original_scores[original_scores$Project == project & original_scores$Bug == bugid & original_scores$Formula == fomular,]) == 0){
    print (paste("remove ", project,"-", bugid/100000, sep=""))
    remove_array<-c(remove_array,i)
  } 
}
if (length(remove_array) > 0) { 
  minimized_scores<- minimized_scores[-remove_array,]
}
minimized_scores[order(minimized_scores$Project,minimized_scores$Bug,minimized_scores$Formula),]

remove_array <- integer()
for (i in 1:nrow(original_scores)) {
  bugid = (original_scores [i,]$Bug)[1]/100000
  project= (original_scores [i,]$Project)[1]
  fomular= (original_scores [i,]$Formula)[1]
  if (nrow(minimized_scores[minimized_scores$Project == project & minimized_scores$Bug == bugid & minimized_scores$Formula == fomular,]) == 0){
    print (paste("remove ", project,"-", bugid*100000, sep=""))
    remove_array<-c(remove_array,i)
  } 
}
if (length(remove_array) > 0) { 
  original_scores <- original_scores[-remove_array,]
}
original_scores[order(original_scores$Project,original_scores$Bug,original_scores$Formula),]

