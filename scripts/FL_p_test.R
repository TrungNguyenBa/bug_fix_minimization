minimized_scores<-read.csv("/Users/trung/Documents/Umass_rs/FL_techniques/fault-localization-data/analysis/pipeline-scripts/Scores/minimized/master_scores.csv")
original_scores<-read.csv("/Users/trung/Documents/Umass_rs/FL_techniques/fault-localization-data/analysis/pipeline-scripts/Scores/original/master_scores.csv")

minimized_scores <- unique(minimized_scores)
original_scores <- unique(original_scores)

Ochiai_m <- minimized_scores[minimized_scores$Formula == "ochiai" & minimized_scores$ScoringScheme == "first",]
Ochiai_non <- original_scores[original_scores$Formula == "ochiai" & original_scores$ScoringScheme == "first" ,]
Barinel_m <- minimized_scores[minimized_scores$Formula == "barinel" & minimized_scores$ScoringScheme == "first" ,]
Barinel_non <-original_scores[original_scores$Formula == "barinel" & original_scores$ScoringScheme == "first",]
Op2_m <- minimized_scores[minimized_scores$Formula == "opt2" & minimized_scores$ScoringScheme == "first",]
Op2_non <- original_scores[original_scores$Formula == "opt2" & original_scores$ScoringScheme == "first",]
DStar_m <- minimized_scores[minimized_scores$Formula == "dstar2" & minimized_scores$ScoringScheme == "first",]
DStar_non <-original_scores[original_scores$Formula == "dstar2"  & original_scores$ScoringScheme == "first",]
Tarantula_m <- minimized_scores[minimized_scores$Formula == "tarantula" & minimized_scores$ScoringScheme == "first",]
Tarantula_non <- original_scores[original_scores$Formula == "tarantula" & original_scores$ScoringScheme == "first",]
Muse_m <- minimized_scores[minimized_scores$Formula == "muse" & minimized_scores$ScoringScheme == "first" ,]
Muse_non <- original_scores[original_scores$Formula == "muse" & original_scores$ScoringScheme == "first",]
Jaccard_m <- minimized_scores[minimized_scores$Formula == "jaccard" & minimized_scores$ScoringScheme == "first",]
Jaccard_non <- original_scores[original_scores$Formula == "jaccard" & original_scores$ScoringScheme == "first",]
library(effsize)
#RQ1 evaluation


#RQ2 evaluation

#Ochiai > Tarantula
m1 <- t.test(Tarantula_m$Score,Ochiai_m$Score, paired=T)
cohen.d(Tarantula_m$Score,Ochiai_m$Score,paired = TRUE)
#Barinel > Ochiai 
m2 <- t.test(Ochiai_m$Score,Barinel_m$Score, paired=T) 
cohen.d(Barinel_m$Score, Ochiai_m$Score, paired = TRUE)
#Barinel > Tarantula
m3 <- t.test(Tarantula_m$Score,Barinel_m$Score, paired=T)
cohen.d(Barinel_m$Score, Tarantula_m$Score, paired = TRUE)
#Op2 > Ochiai
m4 <- t.test(Ochiai_m$Score,Op2_m$Score, paired=T)
cohen.d(Op2_m$Score, Ochiai_m$Score,   paired = TRUE)
#Op2 > Tarantula
m5 <- t.test(Tarantula_m$Score,Op2_m$Score, paired=T)
cohen.d(Op2_m$Score, Tarantula_m$Score,paired = TRUE)
#DStar > Ochiai
m6 <- t.test(Ochiai_m$Score,DStar_m$Score, paired=T)
cohen.d(DStar_m$Score, Ochiai_m$Score,   paired = TRUE)
#DStar > Tarantula 
m7 <- t.test(Tarantula_m$Score,DStar_m$Score ,paired=T)
cohen.d(DStar_m$Score, Tarantula_m$Score, paired = TRUE)

#Ochiai > Tarantula
non1 <- t.test(Tarantula_non$Score,Ochiai_non$Score,  paired=T)
cohen.d(Ochiai_non$Score, Tarantula_non$Score,  paired = TRUE)
#Barinel > Ochiai 
non2 <- t.test(Ochiai_non$Score,Barinel_non$Score, paired=T) 
cohen.d(Barinel_non$Score, Ochiai_non$Score,   paired = TRUE)
#Barinel > Tarantula
non3 <- t.test(Tarantula_non$Score,Barinel_non$Score, paired=T)
cohen.d(Barinel_non$Score, Tarantula_non$Score,  paired = TRUE)
#Op2 > Ochiai
non4 <- t.test(Ochiai_non$Score,Op2_non$Score, paired=T)
cohen.d(Op2_non$Score, Ochiai_non$Score,  paired = TRUE)
#Op2 > Tarantula
non5 <- t.test(Tarantula_non$Score,Op2_non$Score, paired=T)
cohen.d(Op2_non$Score, Tarantula_non$Score,  paired = TRUE)
#DStar > Ochiai
non6 <- t.test(Ochiai_non$Score,DStar_non$Score ,paired=T)
cohen.d(DStar_non$Score, Ochiai_non$Score,  paired = TRUE)
#DStar > Tarantula 
non7 <- t.test(Tarantula_non$Score,DStar_non$Score, paired=T)
cohen.d(DStar_non$Score, Tarantula_non$Score,  paired = TRUE)


