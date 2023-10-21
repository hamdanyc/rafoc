# minit_import_db.R

# read data ----
library(mongolite)
library(dplyr)

# Connect db
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
# convert json to a singlr line
# tr -d '\n' < minit_exco_1_23.json > minit.json && add \n

system("tr -d '\n' < min_exco_3m_23.json > minit.json && sed -i -e '$a\n' minit.json")
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="minit", db="rafoc", url=con)

# import-export db ----
rs <- db$find('{"Siri": "3m/23", "Jenis": "exco"}')
if (nrow(rs) != 0) db$remove('{"Siri": "3m/23", "Jenis": "exco"}')
db$import(file("minit.json"))
# db$export(file("dump.json"))
