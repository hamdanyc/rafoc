# ahli_init.R

# Init ----
library(mongolite)
library(dplyr)
library(janitor)
library(googlesheets4)
library(jsonlite)
library(lubridate)

# Connect to MongoDB ----
# url <- readLines(con=".url.txt")
# db <- mongolite::mongo(collection="ahli", db="rafoc", url=url)
# Get password from environment variable

USER_ID <- Sys.getenv("USER_ID")
PASSWORD <- Sys.getenv("PASSWORD")
DB_SVR <- Sys.getenv("DB_SVR")
db <- mongo(collection = "ahli", db = "rafoc", url = paste0("mongodb://", USER_ID, ":", PASSWORD, "@", DB_SVR))
# function to query database ----
fp <- function(field, pattern) {
  pattern <- toupper(pattern)
  qry <- paste0('{"', field, '": {"$regex": "', pattern, '"}}')
  db$find(qry, fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
}

# read google spreadsheet file from google drive ----
ss <- gs4_get("https://docs.google.com/spreadsheets/d/1AFRvt7wmRFepVThPW3ikItWRWxdSeZz91K9utUqbTS0/edit?resourcekey#gid=621805772")
rs <- read_sheet(ss, sheet = 1) %>% 
  clean_names() %>%
  rename(no_kp = no_kad_pengenalan_mykad, pkt = pangkat_ketika_bersara) %>%
  mutate(no_kp = as.character(no_kp), no_tel = as.character(no_tel),
         no_kp = stringr::str_replace_all(no_kp," ",""),
         no_kp = stringr::str_replace_all(no_kp,"-",""),
         no_tel = stringr::str_replace_all(no_tel,"-",""),
         no_tel = stringr::str_replace_all(no_tel," ",""),
         no_tentera = stringr::str_replace_all(no_tentera,"N|T|/",""),
         mth = month(timestamp),
         alamat = stringr::str_replace_all(alamat,"\n"," ")) %>% 
  filter(no_kp != "") %>% 
  filter(nama != "") %>% 
  distinct(no_kp, .keep_all = TRUE) 

# db$update from data frame rs ----
for (i in 1:nrow(rs)) {
  data <- toJSON(list(
    no_kp = rs$no_kp[i],
    alamat_tetap1 = stringr::str_to_upper(rs$alamat[i]),
    alamat_tetap2 = "",
    nama = stringr::str_to_upper(rs$nama[i]),
    no_tentera = rs$no_tentera[i],
    pkt = rs$pkt[i],
    email = rs$e_mail[i],
    ttp = rs$tarikh_bersara[i],
    no_tel = rs$no_tel[i]
  ), auto_unbox = TRUE)
  
  db$update(
    paste0('{"no_kp": "', rs$no_kp[i], '"}'),
    paste0('{"$set": ', data, '}'),
    upsert = TRUE
  )
}

# db$update from data frame rs ----
# for (i in 1:nrow(rs)) {
#   db$update(
#     paste0('{"no_kp": "', rs$no_kp[i], '"}'),
#     paste0('{"$set": {"alamat_tetap1": "', stringr::str_to_upper(rs$alamat[i]),
#            '", "alamat_tetap2": "',"",
#            '", "nama": "', stringr::str_to_upper(rs$nama[i]),
#            '", "no_tentera": "', rs$no_tentera[i],
#            '", "pkt": "', rs$pkt[i],
#            '", "email": "', rs$e_mail[i],
#            '", "ttp": "', rs$tarikh_bersara[i],
#            '", "no_tel": "', rs$no_tel[i], '"}}'),
#     upsert = TRUE
#   )
# }

# close connection ----
db$disconnect()

# save data frame to csv ----
column_names <- c("Name","Given Name","Additional Name","Family Name",
                  "Yomi Name","Given Name Yomi","Additional Name Yomi",
                  "Family Name Yomi","Name Prefix","Name Suffix",
                  "Initials","Nickname","Short Name","Maiden Name",
                  "Birthday","Gender","Location","Billing Information",
                  "Directory Server","Mileage","Occupation","Hobby",
                  "Sensitivity","Priority","Subject","Notes","Language","Photo","Group Membership",
                  "E-mail 1 - Type","E-mail 1 - Value","E-mail 2 - Type","E-mail 2 - Value",
                  "Phone 1 - Type","Phone 1 - Value","Phone 2 - Type","Phone 2 - Value",
                  "Organization 1 - Type","Organization 1 - Name",
                  "Organization 1 - Yomi Name","Organization 1 - Title",
                  "Organization 1 - Department","Organization 1 - Symbol",
                  "Organization 1 - Location","Organization 1 - Job Description")

contact <- rs %>% 
    mutate(Name = nama, "Given Name" ="","Additional Name" = "","Family Name" = "","Yomi Name" = "",
           "Given Name Yomi" = "","Additional Name Yomi" = "","Family Name Yomi" = "",
           "Name Prefix" = "","Name Suffix" = "","Initials" = "","Nickname" = "","Short Name" = "","Maiden Name" = "",
           "Birthday" = "","Gender" = "","Location" = "","Billing Information" = "",
           "Directory Server" = "","Mileage" = "","Occupation" = "","Hobby" = "","Sensitivity" = "",
           "Priority" = "","Subject" = "","Notes" = "","Language" = "","Photo" = "","Group Membership" = "rafoc ::: * myContacts",
           "E-mail 1 - Type" = "","E-mail 1 - Value" = e_mail,"E-mail 2 - Type" = "","E-mail 2 - Value" = "",
           "Phone 1 - Type" = "Mobile","Phone 1 - Value" = no_tel,"Phone 2 - Type" = "","Phone 2 - Value" = "",
           "Organization 1 - Type" = "","Organization 1 - Name" = "RAFOC","Organization 1 - Yomi Name" = "",
           "Organization 1 - Title" = "","Organization 1 - Department" = "",
           "Organization 1 - Symbol" = "","Organization 1 - Location" = "","Organization 1 - Job Description" = "") %>% 
  filter(mth == month(today()))

  contact %>%  select(Name,"Given Name","Additional Name","Family Name",
           "Yomi Name","Given Name Yomi","Additional Name Yomi",
           "Family Name Yomi","Name Prefix","Name Suffix",
           "Initials","Nickname","Short Name","Maiden Name",
           "Birthday","Gender","Location","Billing Information",
           "Directory Server","Mileage","Occupation","Hobby",
           "Sensitivity","Priority","Subject","Notes","Language","Photo","Group Membership",
           "E-mail 1 - Type","E-mail 1 - Value","E-mail 2 - Type","E-mail 2 - Value",
           "Phone 1 - Type","Phone 1 - Value","Phone 2 - Type","Phone 2 - Value",
           mth,
           "Organization 1 - Type","Organization 1 - Name",
           "Organization 1 - Yomi Name","Organization 1 - Title",
           "Organization 1 - Department","Organization 1 - Symbol",
           "Organization 1 - Location","Organization 1 - Job Description") 
names(contact) <- column_names
           
readr::write_csv(rs, "ahli_mohon.csv")
readr::write_csv(contact, "ahli_contact.csv")
save(list= "rs",file="ahli.RData")


