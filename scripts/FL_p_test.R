

print ("here")
Ochiai_m <- minimized_scores[minimized_scores$Formula == "ochiai" ,]
Ochiai_non <- original_scores[original_scores$Formula == "ochiai" ,]
Barinel_m <- minimized_scores[minimized_scores$Formula == "barinel" ,]
Barinel_non <- original_scores[original_scores$Formula == "barinel",]
Op2_m <- minimized_scores[minimized_scores$Formula == "opt2" ,]
Op2_non <- original_scores[original_scores$Formula == "opt2",]
DStar_m <- minimized_scores[minimized_scores$Formula == "dstar2" ,]
DStar_non <-original_scores[original_scores$Formula == "dstar2" ,]
Tarantula_m <- minimized_scores[minimized_scores$Formula == "tarantula" ,]
Tarantula_non <- original_scores[original_scores$Formula == "tarantula",]
Muse_m <- minimized_scores[minimized_scores$Formula == "muse"  ,]
Muse_non <- original_scores[original_scores$Formula == "muse",]
Jaccard_m <- minimized_scores[minimized_scores$Formula == "jaccard" ,]
Jaccard_non <- original_scores[original_scores$Formula == "jaccard",]
library(effsize)
#RQ1 evaluation


#RQ2 evaluation

#Ochiai > Tarantula
#minimized
print (length(Tarantula_m) == length(Ochiai_m))
m1 <- t.test(Tarantula_m$ScoreWRTLoadedClasses,Ochiai_m$ScoreWRTLoadedClasses, paired = T)
c1 <- cohen.d(Tarantula_m$ScoreWRTLoadedClasses,Ochiai_m$ScoreWRTLoadedClasses, paired = T)
#Barinel > Ochiai 
m2 <- t.test(Ochiai_m$ScoreWRTLoadedClasses,Barinel_m$ScoreWRTLoadedClasses, paired = T) 
c2 <- cohen.d( Ochiai_m$ScoreWRTLoadedClasses,Barinel_m$ScoreWRTLoadedClasses, paired = T)
#Barinel > Tarantula
m3 <- t.test(Tarantula_m$ScoreWRTLoadedClasses,Barinel_m$ScoreWRTLoadedClasses, paired = T)
c3 <- cohen.d(Tarantula_m$ScoreWRTLoadedClasses,Barinel_m$ScoreWRTLoadedClasses, paired = T)
#Op2 > Ochiai
print(nrow(Ochiai_m))
m4 <- t.test(Ochiai_m$ScoreWRTLoadedClasses,Op2_m$ScoreWRTLoadedClasses, paired = T)
c4 <- cohen.d(Ochiai_m$ScoreWRTLoadedClasses,Op2_m$ScoreWRTLoadedClasses, paired = T)
#Op2 > Tarantula
m5 <- t.test(Tarantula_m$ScoreWRTLoadedClasses,Op2_m$ScoreWRTLoadedClasses, paired = T)
c5 <- cohen.d(Tarantula_m$ScoreWRTLoadedClasses,Op2_m$ScoreWRTLoadedClasses, paired = T)
#DStar > Ochiai
m6 <- t.test(Ochiai_m$ScoreWRTLoadedClasses,DStar_m$ScoreWRTLoadedClasses, paired = T)
c6 <- cohen.d( Ochiai_m$ScoreWRTLoadedClasses,DStar_m$ScoreWRTLoadedClasses, paired = T)
#DStar > Tarantula 
m7 <- t.test(Tarantula_m$ScoreWRTLoadedClasses,DStar_m$ScoreWRTLoadedClasses, paired = T )
c7 <- cohen.d(Tarantula_m$ScoreWRTLoadedClasses,DStar_m$ScoreWRTLoadedClasses, paired = T)
Ccm <- c(c1["estimate"],c2["estimate"],c3["estimate"],c4["estimate"],c5["estimate"],c6["estimate"],c7["estimate"])
Cpm <- c(m1["p.value"],m2["p.value"],m3["p.value"],m4["p.value"],m5["p.value"],m6["p.value"],m7["p.value"])



# non-minimized
m1 <- t.test(Tarantula_non$ScoreWRTLoadedClasses,Ochiai_non$ScoreWRTLoadedClasses, paired = T)
c1 <- cohen.d(Tarantula_non$ScoreWRTLoadedClasses,Ochiai_non$ScoreWRTLoadedClasses, paired = T)
#Barinel > Ochiai 
m2 <- t.test(Ochiai_non$ScoreWRTLoadedClasses,Barinel_non$ScoreWRTLoadedClasses, paired = T) 
c2 <- cohen.d( Ochiai_non$ScoreWRTLoadedClasses,Barinel_non$ScoreWRTLoadedClasses, paired = T)
#Barinel > Tarantula
m3 <- t.test(Tarantula_non$ScoreWRTLoadedClasses,Barinel_non$ScoreWRTLoadedClasses, paired = T)
c3 <- cohen.d(Tarantula_non$ScoreWRTLoadedClasses,Barinel_non$ScoreWRTLoadedClasses, paired = T)
#Op2 > Ochiai
print(nrow(Ochiai_non))
m4 <- t.test(Ochiai_non$ScoreWRTLoadedClasses,Op2_non$ScoreWRTLoadedClasses, paired = T)
c4 <- cohen.d(Ochiai_non$ScoreWRTLoadedClasses,Op2_non$ScoreWRTLoadedClasses, paired = T)
#Op2 > Tarantula
m5 <- t.test(Tarantula_non$ScoreWRTLoadedClasses,Op2_non$ScoreWRTLoadedClasses, paired = T)
c5 <- cohen.d(Tarantula_non$ScoreWRTLoadedClasses,Op2_non$ScoreWRTLoadedClasses, paired = T)
#DStar > Ochiai
m6 <- t.test(Ochiai_non$ScoreWRTLoadedClasses,DStar_non$ScoreWRTLoadedClasses, paired = T)
c6 <- cohen.d( Ochiai_non$ScoreWRTLoadedClasses,DStar_non$ScoreWRTLoadedClasses, paired = T)
#DStar > Tarantula 
m7 <- t.test(Tarantula_non$ScoreWRTLoadedClasses,DStar_non$ScoreWRTLoadedClasses, paired = T )
c7 <- cohen.d(Tarantula_non$ScoreWRTLoadedClasses,DStar_non$ScoreWRTLoadedClasses, paired = T)
Ccnonm <- c(c1["estimate"],c2["estimate"],c3["estimate"],c4["estimate"],c5["estimate"],c6["estimate"],c7["estimate"])
Cpnonm <- c(m1["p.value"],m2["p.value"],m3["p.value"],m4["p.value"],m5["p.value"],m6["p.value"],m7["p.value"])





Ochiai_old <- old_scores[old_scores$Formula == "ochiai" ,]
Barinel_old <- old_scores[old_scores$Formula == "barinel" ,]
Op2_old <- old_scores[old_scores$Formula == "opt2" ,]
DStar_old <- old_scores[old_scores$Formula == "dstar2" ,]
Tarantula_old <- old_scores[old_scores$Formula == "tarantula" ,]
Muse_old <- old_scores[old_scores$Formula == "muse"  ,]
Jaccard_old <- old_scores[old_scores$Formula == "jaccard" ,]


m1 <- t.test(Tarantula_old$ScoreWRTLoadedClasses,Ochiai_old$ScoreWRTLoadedClasses, paired = T)
c1 <- cohen.d(Tarantula_old$ScoreWRTLoadedClasses,Ochiai_old$ScoreWRTLoadedClasses, paired = T)
#Barinel > Ochiai 
m2 <- t.test(Ochiai_old$ScoreWRTLoadedClasses,Barinel_old$ScoreWRTLoadedClasses, paired = T) 
c2 <- cohen.d( Ochiai_old$ScoreWRTLoadedClasses,Barinel_old$ScoreWRTLoadedClasses, paired = T)
#Barinel > Tarantula
m3 <- t.test(Tarantula_old$ScoreWRTLoadedClasses,Barinel_old$ScoreWRTLoadedClasses, paired = T)
c3 <- cohen.d(Tarantula_old$ScoreWRTLoadedClasses,Barinel_old$ScoreWRTLoadedClasses, paired = T)
#Op2 > Ochiai
print(nrow(Ochiai_old))
m4 <- t.test(Ochiai_old$ScoreWRTLoadedClasses,Op2_old$ScoreWRTLoadedClasses, paired = T)
c4 <- cohen.d(Ochiai_old$ScoreWRTLoadedClasses,Op2_old$ScoreWRTLoadedClasses, paired = T)
#Op2 > Tarantula
m5 <- t.test(Tarantula_old$ScoreWRTLoadedClasses,Op2_old$ScoreWRTLoadedClasses, paired = T)
c5 <- cohen.d(Tarantula_old$ScoreWRTLoadedClasses,Op2_old$ScoreWRTLoadedClasses, paired = T)
#DStar > Ochiai
m6 <- t.test(Ochiai_old$ScoreWRTLoadedClasses,DStar_old$ScoreWRTLoadedClasses, paired = T)
c6 <- cohen.d( Ochiai_old$ScoreWRTLoadedClasses,DStar_old$ScoreWRTLoadedClasses, paired = T)
#DStar > Tarantula 
m7 <- t.test(Tarantula_old$ScoreWRTLoadedClasses,DStar_old$ScoreWRTLoadedClasses, paired = T )
c7 <- cohen.d(Tarantula_old$ScoreWRTLoadedClasses,DStar_old$ScoreWRTLoadedClasses, paired = T)
Ccoldm <- c(c1["estimate"],c2["estimate"],c3["estimate"],c4["estimate"],c5["estimate"],c6["estimate"],c7["estimate"])
Cpoldm <- c(m1["p.value"],m2["p.value"],m3["p.value"],m4["p.value"],m5["p.value"],m6["p.value"],m7["p.value"])




  
  
