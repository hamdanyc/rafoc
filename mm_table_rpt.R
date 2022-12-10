# mm_table_rpt.R

# init ----
library(kableExtra)
library(mongolite)
library(dplyr)

# conn db ----
# mongodb://[username:password@]host1[:port1]/?authSource=user-data

con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="mmmt", db="rafoc", url=con)
tbl <- db$find('{}')

# report ----
tbl %>% 
  filter(Tindakan == "Bayaran diterima") %>% 
  mutate(Siri = row_number(), meja = factor(No_Meja, levels = stringr::str_sort(unique(No_Meja), numeric = TRUE))) %>% 
  group_by(meja) %>%
  arrange(meja) %>% 
  select(No_Meja, Nama, Status, Menu) %>%
  View()

# sort
# y %>%  
#   dplyr::mutate(V1_fac = factor(V1, levels= str_sort(unique(V1), numeric=TRUE))) %>%
#   dplyr::arrange(V1_fac)