library(dplyr)

tb_id <- c("Meja Diraja", "Meja Diraja (Pasangan)", "Tetamu Presiden", "Rombongan Diraja", "Khas:CIMB",
           "MR1:Black Beret (1))/Dato' Barry Tan", "MR2:WestStar/EXCO(1)", "MR3:Sofian Arshad (TJP 31)", "MR4:EXCO(2)",
           "MR5:NADI", "MR6:TJP 18/19/20/21", "MR7:Black Beret (2)/Teras Sepadu", "MR8:RMA Sandhurst", 
           "MR9:RMNOA", "MR10:Black Beret(3)/CIMB","MR11:AFATS", "MR12:Brig Jen Dato’ Hamid (B)", 
           "MR13:Black Beret(4)/CIMB","MR14:Black Beret(5)/CIMB", "MR15:Black beret (6)/CIMB", 
           "MR16:Black Beret (7)/Teras Sepadu", "MR17:Black beret (8)/Michael Choo", "MR18:Mej Datuk Murthi(1)", 
           "MR19:Mej Datuk Murthi(2)", "MR20:Mej Datuk Murthi(3)", "MR21:TJP 31(2)", "MR22:TJP 25",
           "MR23:Kump Ord", "MR24:TUDM", "MR25:Saling Erti", "MR26:KPRAMD", "MR27:KKD", 
           "MR28:PERNAMA", "MR29:AJK", "MR30:PVATM", "MR31:TJT 6", "MR32:ADC", "VVIP (1)", "VVIP (2)")

index <- c("Meja Diraja"=9, "Meja Diraja (Pasangan)"=7, "Tetamu Presiden"=9, "Rombongan Diraja"=10, "Khas:CIMB"=10,
          "MR1:Black Beret (1))/Dato' Barry Tan"=10, "MR2:WestStar/EXCO(1)"=10, "MR3:Sofian Arshad (TJP 31)"=10, "MR4:EXCO(2)"=10,
          "MR5:NADI"=10, "MR6:TJP 18/19/20/21"=9, "MR7:Black Beret (2)/Teras Sepadu"=10, "MR8:RMA Sandhurst"=10, 
          "MR9:RMNOA"=9, "MR10:Black Beret(3)/CIMB"=10,"MR11:AFATS"=10, "MR12:Brig Jen Dato’ Hamid (B)"=10, 
          "MR13:Black Beret(4)/CIMB"=10,"MR14:Black Beret(5)/CIMB"=10, "MR15:Black beret (6)/CIMB"=10, 
          "MR16:Black Beret (7)/Teras Sepadu"=10, "MR17:Black beret (8)/Michael Choo"=10, "MR18:Mej Datuk Murthi(1)"=10, 
          "MR19:Mej Datuk Murthi(2)"=10, "MR20:Mej Datuk Murthi(3)"=10, "MR21:TJP 31(2)"=10, "MR22:TJP 25"=10,
          "MR23:Kump Ord"=10, "MR24:TUDM"=8, "MR25:Saling Erti"=10, "MR26:KPRAMD"=10, "MR27:KKD"=10, 
          "MR28:PERNAMA"=10, "MR29:AJK"=9, "MR30:PVATM"=10, "MR31:TJT 6"=10, "MR32:ADC"=3, "VVIP (1)"=9, "VVIP (2)"=9)

tb_cnt <- tbl %>% 
  # filter(Tindakan != "Tidak hadir") %>% 
  mutate(Meja = factor(No_Meja, levels = stringr::str_sort(unique(No_Meja), numeric = TRUE))) %>% 
  group_by(Meja) %>%
  summarise(n=n())

x <- c(1, 2, 3, 4, 5)
y <- c("a", "b", "c", "d", "e")
z <- setNames(tb_cnt$n,tb_id)
