# rm_upd_bio.R

# Init ----
library(dplyr)
load("rafoc.RData")

# Update ----
rf_df <- peg_vet %>% 
  left_join(atm_vet,by =c("kp_noten")) %>%
  select('NAMA AHLI(IdentityName)'= Nama.x,
         'NO.MYKAD(IdentityID)' = kp_icbaru.x,
         'Alamat Tetap (StayingAddress1)' = kp_alamat,
         'No. Tentera (MilitaryNo)' = kp_noten,
         'TARIKH PENYERTAAN(MemberjoinDate)' = kp_ttp.x) %>% 
  mutate('KATEGORI AHLI(MemberTypeCode)' = "AHLI SEUMUR HIDUP",
         'EMEL(EmailAddress)' = "",
         'Alamat Tetap (StayingAddress2)' = "",
         'StayingAddressPostCode' = "",
         'StayingAddressTown'= "",
         'StayingAddressState' = "",
         'Alamat Tetap (StayingAddress3)' = "",
                  'PEKERJAAN (JobOccupation)' = "",
         'Alamat Pekerjaan (MailingAddress1)' = "",
         'Alamat Pekerjaan (MailingAddress2)' = "",
         'Alamat Pekerjaan (MailingAddress3)' = "",
         'MailingAddressPostCode' = "",
         'MailingAddressTown' = "",
         'MailingAddressState' = "",
         'No. Telefon (PhoneNo)' = "",
 ) %>% 
  select('NAMA AHLI(IdentityName)', 'NO.MYKAD(IdentityID)',
         'TARIKH PENYERTAAN(MemberjoinDate)','KATEGORI AHLI(MemberTypeCode)',
         'EMEL(EmailAddress)','Alamat Tetap (StayingAddress1)',
         'Alamat Tetap (StayingAddress2)','Alamat Tetap (StayingAddress3)',
         'StayingAddressPostCode',
         'StayingAddressTown',
         'StayingAddressState',
         'PEKERJAAN (JobOccupation)',
         'Alamat Pekerjaan (MailingAddress1)',
         'Alamat Pekerjaan (MailingAddress2)',
         'Alamat Pekerjaan (MailingAddress3)',
         'MailingAddressPostCode',
         'MailingAddressTown',
         'MailingAddressState',
         'No. Telefon (PhoneNo)',
         'No. Tentera (MilitaryNo)')

# save file ----
write_csv(rf_df,"ahli_rafoc.csv")
         
