setwd("/Users/trung/Documents/Umass_rs/bug_fix_minimization/plots/D4J")
getwd()
#D4J plots

line_diff = merge_diff$ins_diff + merge_diff$del_diff + merge_diff$mod_diff
normal = merge_diff$INS + merge_diff$DEL + merge_diff$MOD
png(filename="Line_DIF.png")
percentage = (line_diff)/normal*100
percentage = percentage[percentage < 400 & percentage >0]
plot(density(percentage),main="Distribution of differences in number of changed lines",xlab="Increase percentage",xaxt='n',xlim=c(0,400),breaks=seq(0,400,by=20))
axis(1, at = seq(0, 400, by = 20))
dev.off()
png(filename="File_DIF.png")
plot(density((as.numeric(commit_changes_files[commit_changes_files$nf_diff <= 400,]$nf_diff))/as.numeric(commit_changes_files[commit_changes_files$nf_diff <= 300,]$nfcm)*100),main="Distribution of differences in number of changed files",xlab="Increase percentage",xaxt='n',xlim=c(0,400),breaks=seq(0,400,by=20))
axis(1, at = seq(0, 400, by = 20))
dev.off()
setwd("/Users/trung/Documents/Umass_rs/bug_fix_minimization/plots/testedness")
getwd()
#testedness plots
#png(filename="inserted.png")
#plot(density(testedness_dff$inserted),main="Distribution of inserted lines",xlab="lines",xaxt='n')
#axis(1, at = seq(-5, 60, by = 3))
#dev.off()
#png(filename="deleled.png")
#plot(density(testedness_dff$deleted),main="Distribution of deleted lines",xlab="lines",xaxt='n')
#axis(1, at = seq(-5, 60, by = 3))
#dev.off()
#png(filename="modified.png")
#plot(density(testedness_dff$modified),main="Distribution of modified lines",xlab="lines",xaxt='n')
#axis(1, at = seq(-5, 60, by = 3))
#dev.off()