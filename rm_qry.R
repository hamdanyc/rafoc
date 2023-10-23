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
# convert to a function with parameter field and pattern ----
# display no_kp and nama as fields
pattern <- "[0-9]"
fp <- function(field, pattern) {
  pattern <- toupper(pattern)
  qry <- paste0('{"', field, '": {"$regex": "', pattern, '"}}')
  db$find(qry, fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
}

# find pattern in nama field, select no_kp,nama,no_tentera  ----
pers<- fp("alamat_tetap1", "selangor") %>% 
  select(no_kp, nama, no_tentera, alamat_tetap1)

# Replace pattern with white space in pers$nama to data frame ----
pers$nama <- gsub(pattern, "", pers$nama)

# update nama from data frame pers ---
for (i in 1:nrow(pers)) {
  query <- paste0('{"no_kp": "', pers$no_kp[i], '"}')
  update <- paste0('{"$set": {"nama": "', pers$nama[i], '"}}')
  db$update(query, update)
}

#find duplicate no_kp ----
dp <- db$aggregate('[{"$group": {"_id": "$no_kp", "count": {"$sum": 1}}}, {"$match": {"count": {"$gt": 1}}}]')
# project nama and no_tentera
dp <- db$aggregate('[{"$group": {"_id": "$no_kp", "count": {"$sum": 1}, 
                   "nama": {"$push": "$nama"}, 
                   "no_tentera": {"$push": "$no_tentera"}}},
                   {"$match": {"count": {"$gt": 1}}}]')
# clean up dp
dp <- dp %>% 
  mutate(nama = sapply(nama, function(x) paste(x, collapse = ", ")),
         no_tentera = sapply(no_tentera, function(x) paste(x, collapse = ", ")))

# remove the duplicate _id and skip first row

for (i in 1:nrow(dp)) {
  query <- paste0('{"no_kp": "', dp$`_id`[i], '"}')
  # skip first row
  db$remove(query,just_one = TRUE)
}

# Find & update ----
# subjects$update('{}', '{"$set":{"has_age": false}}', multiple = TRUE)
db$update(qry, '{"$set": {"alamat_tetap1": "45, JALAN 1/27D, SEKSYEN 6, WANGSA MAJU",
          "email": "hamdan.hy@gmail.com"}}')

# Close connection ----
db$disconnect()



