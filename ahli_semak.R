# ahli_semak.R
# update single record ----
db$update(
  '{"no_kp": "571212025699"}',
  '{"$set": {"nama": "ABDUL GHANI BIN OTHMAN"}}',
  multiple = TRUE
)

df_rs %>% db$update(
  '{"no_kp": no_kp}',
  paste0('{"$set": {"alamat_tetap1": "', df$alamat_tetap1[i], '"}}'),
  multiple = TRUE
)

# db$find() rec use df_rs$no_kp as value key ----
# display all records with no_kp = df_rs$no_kp[i]
db$find(paste0('{"no_kp": "', df_rs$no_kp[11], '"}'))

# query database filter e_mail not empty ----
rs_bak <- df %>% 
  filter(!is.na(e_mail)) %>% 
  mutate(e_mail = stringr::str_to_lower(e_mail)) %>% 
  select(no_kp, e_mail)

# unset field e_mail from database ----
db$update(
  '{}',
  '{"$unset": {"e_mail": ""}}',
  multiple = TRUE
)

# aggregate total group by pkt, main total at bottom ----
tbypkt <- df %>% 
  group_by(pkt) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) %>% 
  add_row(pkt = "JUMLAH", total = sum(.$total))

# aggregate total group by negeri, main total at bottom ----
# negeri <- regex from alamat_tetap1
# list of negeri
negeri <- c("JOHOR", "KEDAH", "KELANTAN", "MELAKA", "NEGERI SEMBILAN", 
            "PAHANG", "PERAK", "PERLIS", "PULAU PINANG", "SABAH", 
            "SARAWAK", "SELANGOR", "TERENGGANU", "WILAYAH PERSEKUTUAN")
# filter negeri from alamat_tetap1
df_negeri <- df %>% 
  filter(stringr::str_detect(alamat_tetap1, paste(negeri, collapse = "|"))) %>% 
  mutate(negeri = stringr::str_extract(alamat_tetap1, paste(negeri, collapse = "|"))) %>% 
  group_by(negeri) %>% 
  summarise(total = n()) %>% 
  arrange(desc(total)) %>% 
  add_row(negeri = "JUMLAH", total = sum(.$total))


