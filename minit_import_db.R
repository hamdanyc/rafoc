# minit_import_db.R
# convert json to a singlr line
# tr -d '\n' < minit_exco_1_23.json > minit.json && add \n

# Init ----
library(mongolite)
library(dplyr)

# Load db ----
# not run
# con <- readLines(con=".url.txt")
# db <- mongolite::mongo(collection="minit", db="rafoc", url=con)
USER_ID <- Sys.getenv("USER_ID2")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "ahli", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))

# convert json to a single line
system("tr -d '\n' < minit_exco_1_24.json > minit.json && sed -i -e '$a\n' minit.json")


# Get doc from db ----
# qry <- paste0('{"Siri": "', siri, "\",", "\"Jenis\": \"exco\"}")
siri <- "1/24"
rs <- db$find(paste0('{"Siri": "', siri, "\",", "\"Jenis\": \"exco\"}"))
if (nrow(rs) != 0) db$remove(paste0('{"Siri": "', siri, "\",", "\"Jenis\": \"exco\"}"))
db$import(file("minit.json"))

# Get Hadir, Tidak_hadir from google sheet ----
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

# embed
# {"$set": {"Hadir": {"Nama": "nama", "Singkatan": "singkatan", "Jawatan": "jawatan"}},
#         {"Tidak_hadir": {"Nama": "nama.x", "Singkatan": "singkatan.x", "Jawatan": "jawatan.x"}}}

# Update fields Hadir, Tidak_hadir db ----
db$update(
  paste0(paste0('{"Siri": "', siri, "\",", "\"Jenis\": \"exco\"}")),
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
