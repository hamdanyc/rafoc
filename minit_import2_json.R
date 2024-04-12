# minit_import2_json.R
# Modify attend list from G.Sheet
# Run minit_exco_db.Rmd for minutes

# Init ----
library(mongolite)
library(dplyr)
library(jsonlite)
library(googlesheets4)

# Load db ----
# not run
# con <- readLines(con=".url.txt")
# db <- mongolite::mongo(collection="minit", db="rafoc", url=con)
USER_ID <- Sys.getenv("USER_ID2")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "minit", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))

# convert json to a single line
system("tr -d '\n' < minit_upload.json > minit.json && sed -i -e '$a\n' minit.json")

# Get doc from db ----
siri <- "1/24"
jenis <- "exco"

# Create a named list
doc <- list(Siri = siri, Jenis = jenis)

# Convert named list to JSON query
query <- toJSON(doc, auto_unbox = TRUE) %>% 
  as.character()

# Find a document in a MongoDB collection
rs <- db$find(query) 

if (nrow(rs) != 0) db$remove(query)
db$import(file("minit.json"))

# From google sheet ----
# rafoc <- mesy jk <- ajk
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1WUpXso8buhZAgC1Ya4uFGTFw3fiTE4ligyAFfPJ_nt4/edit#gid=0")
dfy <- read_sheet(ss, sheet = 1) %>% 
  select(Nama, Singkatan, Jawatan, Hadir) %>% 
  filter(Hadir == "Ya")
dft <- read_sheet(ss, sheet = 1) %>% 
  filter(Hadir == "Tidak")

# Update document
update_document <- list(
  "$set" = list(
    Hadir = list(
      Nama = dfy$Nama,
      Singkatan = dfy$Singkatan,
      Jawatan = dfy$Jawatan
    ),
    Tidak_hadir = list(
      Nama = dft$Nama,
      Singkatan = dft$Singkatan,
      Jawatan = dft$Jawatan
    )
  )
)

# Convert the update document to JSON
update_json <- jsonlite::toJSON(update_document, auto_unbox = TRUE)

# Perform the update operation
db$update(
  query = query,
  update = update_json,
  upsert = TRUE
)
