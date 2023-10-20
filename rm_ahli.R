# rm_ahli.R

# Init ----
library(dplyr)
load("rafoc.RData")

# Update ----
rf_df <- peg_vet %>% 
  left_join(rafoc_alamat,by =c("kp_noten" = "NOTEN")) %>%
  select('nama'= Nama,
         'no_kp' = kp_icbaru,
         'no_tentera' = kp_noten,
         'alamat_tetap1' = m01_alamat_tetap1,
         'alamat_tetap2' = m01_alamat_tetap2,
         'pkt' = c45_desc_pangkat,
         'ttp' = kp_ttp)
# save file ----
readr::write_csv(rf_df,"ahli_rafoc.csv")
         
rf_df %>% 
  filter(is.na(alamat_tetap1)) %>% count()
