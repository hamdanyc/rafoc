# mm_init.R
# insert MMM db then run mm_tb_v1.Rmad (Senarai tetamu/meja)

# Init ----
library(mongolite)
library(dplyr)
library(janitor)
library(googlesheets4)
library(jsonlite)

# Connect to MongoDB 
# Init db
# Get password from environment variable
# url <- readLines(con=".url.txt")
# db <- mongolite::mongo(collection="ahli", db="rafoc", url=url)

USER_ID <- Sys.getenv("USER_ID2")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "mmmt", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))
db$remove('{}')

# read google spreadsheet file from google drive ----
# senarai tetamu MMM
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1rDW3zgMxTDc4O7CLb2B88eeZotk4z9o3kLhtz0q2A4E/edit#gid=1561291431")
guest <- read_sheet(ss, sheet = 1)

# db$update from data frame guest ----
guest <- mutate(guest, Catatan = if_else(is.na(Catatan)," ",Catatan))
for (i in 1:nrow(guest)) {
  data <- toJSON(list(
    Nama = guest$Nama[i],
    Kategori = guest$Kategori[i],
    Menu = guest$Menu[i],
    No_Meja = guest$No_Meja[i],
    Status = guest$Status[i],
    Tindakan = guest$Tindakan[i],
    Catatan = guest$Catatan[i]), auto_unbox = TRUE)
  
  db$update(
    paste0('{"Nama": "', guest$Nama[i], '"}'),
    paste0('{"$set": ', data, '}'),
    upsert = TRUE
  )
}

# close connection 
db$disconnect()


