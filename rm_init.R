# rm_init.R

# init ----

library("DT")
library("data.table")
library("lubridate")
library(dplyr)

# load data ----
df <- fread("peg_2018_2022.csv") # data induk
df$no_kp <- as.character(df$no_kp)
nm <- fread("ahli_jun_22.csv") # mohon ahli
dbm <- inner_join(df,nm,by="no_kp") %>% 
  mutate(notel.x = notel.y, email.x = email.y)

df[no_kp == "600408055179",.(pkt,nama,ttp,notel)]

df[,.(.N),by = .(year(mdy(ttp)))]

# save data ----
save.image("rafoc.RData")
datatable(df)
