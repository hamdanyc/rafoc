# rf_upd_kp.R

# init ----
library(fuzzyjoin)
library(dplyr)
library(stringr)
load("rafoc.RData")

# update Nama, pkt ----
vet_df <- peg_vet %>% 
  mutate("Pangkat" =  case_when(
    c45_desc_pangkat == "JEN" | c45_desc_pangkat == "JEN (PAT)" | c45_desc_pangkat == "JEN(TUDM)" ~ "Jeneral",
    c45_desc_pangkat == "LAKSAMANA" ~ "Laksamana",
    c45_desc_pangkat == "LT JEN" | c45_desc_pangkat == "LT JEN(TUDM)" ~ "Lt Jen",
    c45_desc_pangkat == "LAKDYA" ~ "Laksdya",
    c45_desc_pangkat == "MEJ JEN" | c45_desc_pangkat == "MEJ JEN(TUDM)" ~ "Mej",
    c45_desc_pangkat == "LAKDA" ~ "Laksda",
    c45_desc_pangkat == "BRIG JEN" | c45_desc_pangkat == "BRIG JEN(TUDM)" ~ "Brig Jen",
    c45_desc_pangkat == "LAKSMA" ~ "Laksma",
    c45_desc_pangkat == "KOL" | c45_desc_pangkat == "KOL (TUDM)" ~ "Kol",
    c45_desc_pangkat == "KEPT TLDM" ~ "Kept",
    c45_desc_pangkat == "LT KOL" | c45_desc_pangkat == "LT KOL(TUDM)" ~ "Lt Kol",
    c45_desc_pangkat == "KDR TLDM" ~ "Kdr",
    c45_desc_pangkat == "MEJ" | c45_desc_pangkat == "MEJ(TUDM)" ~ "Mej",
    c45_desc_pangkat == "LT KDR"  ~ "Lt Kdr",
    c45_desc_pangkat == "KAPT" |c45_desc_pangkat == "KAPT(TUDM)" ~ "Kapt",
    c45_desc_pangkat == "LT M" | c45_desc_pangkat == "LT M TLDM" | c45_desc_pangkat == "LTM TLDM" ~ "Lt M",
    c45_desc_pangkat == "LT" | c45_desc_pangkat == "LT DYA TLDM" | c45_desc_pangkat == "LT TLDM" | c45_desc_pangkat == "LT(TUDM)" ~ "Lt",
    TRUE ~ "xxx"),
  "Nama" = stringr::str_replace_all(Nama,"^HJ|DATO'|TAN SRI|DATUK|DATO'|DATUK|PAHLAWAN|SERI ",""),
  "Nama" = stringr::str_to_title(Nama),
  "Nama" = stringr::str_replace(Nama,"Bin","bin"),
  "Nama" = stringr::str_trim(Nama))

rf_df <- rafoc_master %>% filter(!is.na(Pangkat))

# update kp ----
df <- stringdist_left_join(rf_df,vet_df) %>% 
  select(`No Ahli`,Pangkat.x,Gelaran,Nama.x,`No. KP`,"KP Mykad"=kp_icbaru)

df_tmp <- left_join(rafoc_master,vet_df)

df_tmp %>% select(`No Ahli`,Pangkat,Gelaran,Nama,`No. KP`,Khidmat,`No Mykad`=kp_icbaru) %>% 
  write.csv("rafoc_310822.csv")

