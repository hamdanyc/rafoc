# ahli_semak.R

# init ----
library(dplyr)
load("ahli.RData")

# new bre_2 batch, no_kp not in rs ----
bre_2 <- rs %>% 
  anti_join(bre_1, by = "no_kp") %>% 
  select(no_kp, nama, e_mail, pkt, no_tel)

# update single record ----
db$update(
  '{"no_kp": "571212025699"}',
  '{"$set": {"nama": "ABDUL GHANI BIN OTHMAN"}}',
  multiple = TRUE
)

df_rs %>% db$update(
  '{"no_kp": no_kp}',
  paste0('{"$set": {"alamat_tetap1": "', df$alamat_tetap1[i], '"}}'),
  multiple = TRUE
)

# db$find() rec use df_rs$no_kp as value key ----
# display all records with no_kp = df_rs$no_kp[i]
db$find(paste0('{"no_kp": "', df_rs$no_kp[11], '"}'))

# query database filter e_mail not empty ----
rs_bak <- df %>% 
  filter(!is.na(e_mail)) %>% 
  mutate(e_mail = stringr::str_to_lower(e_mail)) %>% 
  select(no_kp, e_mail)

# unset field e_mail from database ----
db$update(
  '{}',
  '{"$unset": {"e_mail": ""}}',
  multiple = TRUE
)

# aggregate total group by pkt, main total at bottom ----
tbypkt <- df %>% 
  group_by(pkt) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) %>% 
  add_row(pkt = "JUMLAH", total = sum(.$total))

# aggregate total group by negeri, main total at bottom ----
# negeri <- regex from alamat_tetap1
# list of negeri
negeri <- c("JOHOR", "KEDAH", "KELANTAN", "MELAKA", "NEGERI SEMBILAN",
            "PAHANG", "PERAK", "PERLIS", "PULAU PINANG", "SABAH", "KELANTAN",
            "SARAWAK","SABAH",  "SELANGOR", "TERENGGANU", "KUALA LUMPUR")
# filter negeri from alamat_tetap1
df_n <- df %>% 
  filter(stringr::str_detect(alamat_tetap1, paste(negeri, collapse = "|"))) %>% 
  mutate(negeri = stringr::str_extract(alamat_tetap1, paste(negeri, collapse = "|"))) %>% 
  group_by(negeri) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) 

df_m <- df %>% 
  filter(stringr::str_detect(alamat_tetap2, paste(negeri, collapse = "|"))) %>% 
  mutate(negeri = stringr::str_extract(alamat_tetap2, paste(negeri, collapse = "|"))) %>% 
  group_by(negeri) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) 

# merge df_n and df_m, calculate total ----
tbyneg <- df_n %>% 
  left_join(df_m, by = "negeri") %>% 
  mutate(total = total.x + total.y) %>% 
  select(negeri, total) %>% 
  arrange(desc(total)) %>% 
  add_row(negeri = "JUMLAH", total = sum(.$total))

# convert timestamp to date format dd/mm/yy ----
rs %>% 
  mutate(tkh = as.Date(timestamp)) %>% 
  select(no_kp, nama, pkt, tkh) %>%
  knitr::kable(caption = "Senarai Ahli Baharu")

# save data frame to csv ----
save.image("ahli.RData")
