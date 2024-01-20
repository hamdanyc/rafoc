ss <- googlesheets4::gs4_get("https://docs.google.com/spreadsheets/d/1AFRvt7wmRFepVThPW3ikItWRWxdSeZz91K9utUqbTS0/edit?resourcekey#gid=621805772")
rs <- googlesheets4::read_sheet(ss, sheet = 1) %>% 
  janitor::clean_names() %>%
  rename(no_kp = no_kad_pengenalan_mykad, pkt = pangkat_ketika_bersara) %>%
  mutate(no_kp = as.character(no_kp), no_tel = as.character(no_tel),
         no_kp = stringr::str_replace_all(no_kp," ",""),
         no_kp = stringr::str_replace_all(no_kp,"-",""),
         no_tel = stringr::str_replace_all(no_tel,"-",""),
         no_tel = stringr::str_replace_all(no_tel," ",""),
         no_tentera = stringr::str_replace_all(no_tentera,"N|T|/",""),
         alamat = stringr::str_replace_all(alamat,"\n"," ")) %>% 
  filter(no_kp != "") %>% 
  filter(nama != "") %>% 
  distinct(no_kp, .keep_all = TRUE)