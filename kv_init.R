# Init ----
library(dplyr)
library(janitor)
library(knitr)
library(googlesheets4)
library(googledrive)
library(mongolite)

# Load data frame from db
USER_ID <- Sys.getenv("USER_ID2")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "ahli", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))

# find path
fi <- drive_ls("~/rafoc/kad veteran") %>% 
  select(key = name) %>% 
  mutate(status = "ada")

# read google spreadsheet file from google drive ----
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1LiI2BGxbUk64WljAf2sYLnalsSIJG-l-HOTLJrNZxWw/edit#gid=822808555")
rs <- read_sheet(ss, sheet = 1) %>% 
  clean_names() %>%
  mutate(no_kp = as.character(no_kp),
         no_kp = stringr::str_replace_all(no_kp," ",""),
         no_kp = stringr::str_replace_all(no_kp,"-",""),
         nama = stringr::str_to_upper(nama),
         no_tel = stringr::str_replace_all(no_tel,".6",""),
         no_tel = stringr::str_replace_all(no_tel,"-",""),
         no_tel = stringr::str_replace_all(no_tel," ",""),
         alamat1 = stringr::str_replace_all(alamat1,"\n",""),
         alamat1 = stringr::str_to_upper(alamat1),
         alamat2 = stringr::str_replace_all(alamat2,"\n"," "),
         alamat2 = stringr::str_to_upper(alamat2),
         key = stringr::str_sub(no_kp,9,12),
  ) %>% 
  filter(no_kp != "") %>% 
  filter(nama != "") %>% 
  distinct(no_kp, .keep_all = TRUE)

# update db ----
for (i in 1:nrow(rs)) {
  db$update(
    paste0('{"no_kp": "', rs$no_kp[i], '"}'),
    paste0('{"$set": {"alamat_tetap1": "', stringr::str_to_upper(rs$alamat1[i]),
           '", "alamat_tetap2": "',stringr::str_to_upper(rs$alamat2[i]),
           '", "nama": "', stringr::str_to_upper(rs$nama[i]),
           '", "no_tel": "', rs$no_tel[i], '"}}'),
    upsert = TRUE
  )
}

# query new rec
df <- db$find()
db$disconnect()
save.image("kv.RData")
