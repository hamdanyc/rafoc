# min_exco_att.R

library(mongolite)
library(dplyr)
library(googlesheets4)

# Connect to the database ----
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
# Load data frame from db
USER_ID <- Sys.getenv("USER_ID2")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "minit", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))
# minit <- db$insert('{"Siri": "1/24", "Jenis": "exco"}')
minit <- db$find('{"Siri": "1/24", "Jenis": "exco"}')

# read google spreadsheet file from google drive ----
# rafoc <- mesy jk <- ajk
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1WUpXso8buhZAgC1Ya4uFGTFw3fiTE4ligyAFfPJ_nt4/edit#gid=0")
dfy <- read_sheet(ss, sheet = 1) %>% 
  select(Nama, Singkatan, Jawatan, Hadir) %>% 
  filter(Hadir == "Ya")
dft <- read_sheet(ss, sheet = 1) %>% 
  filter(Hadir == "Tidak")

# Hadir
Nama <-  dfy$Nama
Singkatan <- dfy$Singkatan
Jawatan <- dfy$Jawatan

nama <- paste0('"',Nama,'"', collapse = ",")
singkatan <- paste0('"',Singkatan,'"',collapse = ",")
jawatan <- paste0('"',Jawatan,'"',collapse = ",")

# Tidak hadir
Nama.x <-  dft$Nama
Singkatan.x <- dft$Singkatan
Jawatan.x <- dft$Jawatan

nama.x <- paste0('"',Nama.x,'"', collapse = ",")
singkatan.x <- paste0('"',Singkatan.x,'"',collapse = ",")
jawatan.x <- paste0('"',Jawatan.x,'"',collapse = ",")

# update db ----
db$update(
  paste0('{"Siri": "1/24", "Jenis": "exco"}'),
  paste0('{"$set": {"Hadir.Nama": [', nama,']',
         ',"Hadir.Singkatan": [', singkatan,']',
         ',"Hadir.Jawatan": [', jawatan,']',
         ',"Tidak_hadir.Nama": [', nama.x,']',
         ',"Tidak_hadir.Singkatan": [', singkatan.x,']',
         ',"Tidak_hadir.Jawatan": [', jawatan.x,
         ']}}'
         ),
  upsert = TRUE
)

# export to json
db$export(file("att.json"), query='{"Siri": "1/24", "Jenis": "exco"}')
