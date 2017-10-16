directory <- "/Users/trung/Documents/Umass_rs/bug_fix_minimization/raw_data/testedness_projects_raw_data"
data <-read.csv("/Users/trung/Documents/Umass_rs/bug_fix_minimization/csv_data/NB_result.csv",header=TRUE, sep=",")
bug_fix<-data[data$label == "Bug-fix",]
bug_fix<-bug_fix[-c(3)]
projects <- unique(bug_fix$project)

for (p in projects) {
  dir.create(file.path(directory, as.character(p)), showWarnings = FALSE)
  folder <- paste(directory,as.character(p),sep="/")
  f <- paste(folder,"commit-data.csv",sep="/")
  print(f)
  commit_data <- bug_fix[bug_fix$project == p,]
  rownames(commit_data) <- 1:nrow(commit_data)
  print(nrow(commit_data))
  write.csv(commit_data, file = f,append=FALSE)
}


