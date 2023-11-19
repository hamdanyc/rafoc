# ahli_init.R

# Init ----
library(mongolite)
library(dplyr)
library(janitor)
library(googlesheets4)

# Connect to MongoDB ----
url <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=url)

# function to query database ----
fp <- function(field, pattern) {
  pattern <- toupper(pattern)
  qry <- paste0('{"', field, '": {"$regex": "', pattern, '"}}')
  db$find(qry, fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
}

# Load data frame from db ----
df <- db$find()

# read google spreadsheet file from google drive ----
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1R_aJ9YPp4IiQZfu1RTw4KLWq5155uCvnu0OuVG_H2q8/edit#gid=1295676957")
rs <- read_sheet(ss, sheet = 1) %>% 
  clean_names() %>%
  rename(no_kp = no_kad_pengenalan_mykad, pkt = pangkat_ketika_bersara) %>%
  mutate(no_kp = as.character(no_kp),
         no_kp = stringr::str_replace_all(no_kp," ",""),
         no_kp = stringr::str_replace_all(no_kp,"-",""),
         no_tentera = stringr::str_replace_all(no_tentera,"N|T|/",""),
         alamat = stringr::str_replace_all(alamat,"\n"," ")) %>% 
  filter(no_kp != "") %>% 
  filter(nama != "") %>% 
  distinct(no_kp, .keep_all = TRUE) 

# Get matching records, set distinct ----
df_rs <- df %>% 
  right_join(rs, by=c("no_kp"="no_kp")) %>%
  filter(no_kp %in% rs$no_kp) %>% 
  distinct(no_kp, .keep_all = TRUE) %>%
  mutate(nama = stringr::str_to_upper(nama.y),
         alamat_tetap1 = stringr::str_to_upper(alamat),
         email = e_mail,
         no_tel = no_tel.y, 
         no_tentera = no_tentera.y,
         pkt = stringr::str_to_upper(pkt.y)) %>% 
  select(no_kp, nama, no_tentera, no_tel, email, alamat_tetap1, pkt, ttp)

# db$update from data frame df_rs ----
for (i in 1:nrow(df_rs)) {
  db$update(
    paste0('{"no_kp": "', df_rs$no_kp[i], '"}'),
    paste0('{"$set": {"alamat_tetap1": "', stringr::str_to_upper(df_rs$alamat_tetap1[i]),
           '", "alamat_tetap2": "',"",
           '", "nama": "', stringr::str_to_upper(df_rs$nama[i]),
           '", "email": "', df_rs$email[i],
           '", "no_tel": "', df_rs$no_tel[i], '"}}'),
    multiple = TRUE
  )
}

# Get non-matching records (new) ----
df_new <- rs %>% 
  filter(!no_kp %in% df$no_kp) %>% 
  mutate(nama = stringr::str_to_upper(nama),
         email = e_mail,
         alamat_tetap1 = stringr::str_to_upper(alamat),
         pkt = stringr::str_to_upper(pkt), ttp = "") %>%
  select(no_kp, nama, no_tentera, no_tel, email, alamat_tetap1, pkt, ttp) %>%
  filter(no_kp != "") %>%
  filter(nama != "")

# insert new records to database ----
db$insert(df_new)

# close connection ----
db$disconnect()

# save data frame to csv ----
save.image("ahli.RData")
readr::write_csv(rs, "ahli_mohon.csv")

