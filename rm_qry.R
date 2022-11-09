# rm_qry.R

# Init ----
library(jsonlite)
library(mongolite)
library(dplyr)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)

# var ----
val <- 3001751
qry <- paste0('{"no_tentera":','"',val,'"}')

# Query data ----
pers <- db$find(qry)
print(pers)
