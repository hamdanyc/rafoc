# rm_qry.R

# Init ----
library(mongolite)
library(dplyr)
library(testthat)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)

# Query data regex nama pattern ----
pattern <- "[0-9]"
qry <- paste0('{"alamat_tetap1": {"$regex": "', pattern, '"}}')
pers <- db$find(qry)

# convert to a function with parameter field and pattern ----
# display no_kp and nama as fields
fp <- function(field, pattern) {
  pattern <- toupper(pattern)
  qry <- paste0('{"', field, '": {"$regex": "', pattern, '"}}')
  db$find(qry, fields='{"_id": 0, "no_kp": 1, "nama": 1}')
}

# find pattern in nama field ----
pers<- fp("nama", "&#039|[0-9]")

# Replace pattern with white space in pers$nama to data frame ----
pattern <- "&#039"
pers$nama <- gsub(pattern, "", pers$nama)

# update nama from data frame pers ---
for (i in 1:nrow(pers)) {
  query <- paste0('{"no_kp": "', pers$no_kp[i], '"}')
  update <- paste0('{"$set": {"nama": "', pers$nama[i], '"}}')
  db$update(query, update)
}

# Find & update ----
# subjects$update('{}', '{"$set":{"has_age": false}}', multiple = TRUE)
db$update(qry, '{"$set": {"alamat_tetap1": "45, JALAN 1/27D, SEKSYEN 6, WANGSA MAJU",
          "email": "hamdan.hy@gmail.com"}}')

# Close connection ----
db$disconnect()



