# rm_qry.R

# Init ----
library(mongolite)
library(dplyr)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)

# var ----
key <- 3001757
qry <- paste0('{"no_tentera":','"',key,'"}')

# Query data ----
pers <- db$find(qry)
print(pers)

# Find & update ----
# subjects$update('{}', '{"$set":{"has_age": false}}', multiple = TRUE)
db$update(qry, '{"$set": {"alamat_tetap1": "45, JALAN 1/27D, SEKSYEN 6, WANGSA MAJU"}}')
