# ahli_semak.R

# Init ---
library(mongolite)
library(dplyr)
library(janitor)

# Connect to MongoDB ---
url <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=url)

# Create a data frame from db ---
df <- db$find()
rs <- read.csv("ahli_gform_res.csv") %>% 
  clean_names() %>%
  rename(no_kp = no_kad_pengenalan_mykad, pkt = pangkat_ketika_bersara) %>%
  mutate(no_kp = as.character(no_kp),
         alamat = stringr::str_replace_all(alamat,"\n"," "))

# Get matching records, set distinct ---
df_rs <- df %>% 
  right_join(rs, by=c("no_kp"="no_kp")) %>%
  filter(no_kp %in% rs$no_kp) %>% 
  distinct(no_kp, .keep_all = TRUE) %>%
  mutate(nama = stringr::str_to_upper(nama.x),
         alamat_tetap = stringr::str_to_upper(alamat),
         no_tel = no_tel.y, 
         no_tentera = no_tentera.x,
         pkt = stringr::str_to_upper(pkt.x)) %>% 
  select(no_kp, nama, no_tentera, no_tel, e_mail, alamat_tetap, pkt, ttp) %>% 
  filter(!is.na(nama)) 

# update alamat from data frame df_rs ---
for (i in 1:nrow(df_rs)) {
  query <- paste0('{"no_kp": "', df_rs$no_kp[i], '"}')
  update <- paste0('{"$set": {"alamat_tetap1": "', df_rs$alamat_tetap[i], 
                   '", "alamat_tetap2": ""}}')
  db$update(query, update)
}

# Get non-matching records (new) ---
df_new <- rs %>% 
  filter(!no_kp %in% df$no_kp) %>% 
  mutate(nama = stringr::str_to_upper(nama),
         alamat_tetap1 = stringr::str_to_upper(alamat),
         pkt = stringr::str_to_upper(pkt), ttp = "") %>%
  select(no_kp, nama, no_tentera, no_tel, e_mail, alamat_tetap1, pkt, ttp) %>%
  filter(!is.na(no_kp)) 

# insert new records to database ---
db$insert(df_new)

# update single record ---
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

# query database from df_rs ---
df_rs %>% db$find(
  '{"no_kp": no_kp}',
  '{"alamat_tetap1": 1, "_id": 0}}'
)

# save data frame to csv ---
write.csv(df_rs, "ahli_2023.csv", row.names = FALSE)
write.csv(df_new, "ahli_2023_new.csv", row.names = FALSE)