# ahli_init.R

# Init ----
library(mongolite)
library(dplyr)
library(janitor)
library(googlesheets4)
library(jsonlite)

# Connect to MongoDB 
# url <- readLines(con=".url.txt")
# db <- mongolite::mongo(collection="ahli", db="rafoc", url=url)
# Get password from environment variable

USER_ID <- Sys.getenv("USER_ID2")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "mmmt", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))
db$remove('{}')

# read google spreadsheet file from google drive ----
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1rDW3zgMxTDc4O7CLb2B88eeZotk4z9o3kLhtz0q2A4E/edit#gid=1561291431")
rs <- read_sheet(ss, sheet = 1)

# db$update from data frame rs ----
rs <- mutate(rs, Catatan = if_else(is.na(Catatan)," ",Catatan))
for (i in 1:nrow(rs)) {
  data <- toJSON(list(
    Nama = rs$Nama[i],
    Kategori = rs$Kategori[i],
    Menu = rs$Menu[i],
    No_Meja = rs$No_Meja[i],
    Status = rs$Status[i],
    Tindakan = rs$Tindakan[i],
    Catatan = rs$Catatan[i]), auto_unbox = TRUE)
  
  db$update(
    paste0('{"Nama": "', rs$Nama[i], '"}'),
    paste0('{"$set": ', data, '}'),
    upsert = TRUE
  )
}

# close connection 
db$disconnect()


