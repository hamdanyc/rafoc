# ahli_outreach.R
# outreach prog to all state

# Init ----
library(mongolite)
library(dplyr)

# Connect to the database
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)
load("ahli.RData")

# convert to function qry by neg ----
qn <- function(negeri) {
  negeri <- toupper(negeri)
  db$find(paste0('{"$or": [{"alamat_tetap1": {"$regex": "', negeri, '"}}, {"alamat_tetap2": {"$regex": "', negeri, '"}}]}'), 
          fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
}

# find db with alamat_tetap2 is NULL
qnull <- db$find('{"alamat_tetap2": "NA"}', fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
pers <- qnull %>% 
  filter(!no_kp %in% rs$no_kp)

# select no_kp,nama,no_tentera,alamat_tetap1,alamat_tetap2,email
# filter is not from rafoc_master
# negeri: Selangor, Kuala Lumpur, N. Sembilan, Melaka, Johor, Pahang, Terengganu, Kelantan, Perlis, Kedah,
# P. Pinang, Sabah, Sarawak
# set file name path to negeri
path <- list("/home/rstudio/out/kl/", "/home/rstudio/out/selangor/", "/home/rstudio/out/ns/",
             "/home/rstudio/out/melaka/", "/home/rstudio/out/johor/", "/home/rstudio/out/pahang/",
             "/home/rstudio/out/terengganu/", "/home/rstudio/out/kelantan/", "/home/rstudio/out/perlis/",
             "/home/rstudio/out/kedah/", "/home/rstudio/out/ppinang/",
             "/home/rstudio/out/sabah/", "/home/rstudio/out/sarawak/", "/home/rstudio/out/na/")

# set output_file to path
output_file <- lapply(path, function(x) x)

# list pers filter by negeri
# pers <- qn("NA") %>% 
#   filter(!no_kp %in%  rf$no_kp) %>%
#   select(no_kp, nama, no_tentera, alamat_tetap1, alamat_tetap2, pkt)

# Print letter ----
# for each record in pers, print out rmarkdown file
for (i in 1:nrow(pers)) {

  # create a list of variables
  vars <- list(
    nama = pers$nama[i],
    no_kp = pers$no_kp[i],
    no_tentera = pers$no_tentera[i],
    alamat_tetap1 = pers$alamat_tetap1[i],
    alamat_tetap2 = pers$alamat_tetap2[i],
    pkt = pers$pkt[i]
  )
  
  # render the rmarkdown file
  rmarkdown::render("ahli_outreach.Rmd", 
                    output_format = "pdf_document", 
                    output_file = paste(output_file[14],"handout_", i, ".pdf", sep=""),
                    params = vars)
}

# query db for pattern in alamat_tetap1 or alamat_tetap2 ----
rs <- db$find('{"$or": [{"alamat_tetap1": {"$regex": "KUALA LUMPUR"}}, {"alamat_tetap2": {"$regex": "KUALA LUMPUR"}}]}',
              fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1,
              "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')

# close connection ----
db$disconnect()

# save work space to ahli.RData ----
save.image("ahli.RData")




