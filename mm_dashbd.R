# mm_dashbd.R

# init ----
library(kableExtra)
library(mongolite)
library(dplyr)
library(ggplot2)
library(plotly)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data

con <- readLines(con=".url.txt")
db  <- mongolite::mongo(collection="ipu", db="rafoc", url=con)
db1 <- mongolite::mongo(collection="tajaan", db="rafoc", url=con)
db2 <- mongolite::mongo(collection="mmmt", db="rafoc", url=con)

# aggregate ----
tajaan <- db1$aggregate('[
  {
    "$group": {
      "_id": {
        "entiti": "$Entiti", 
        "status": "$Tindakan"
      }, 
      "bil": {
        "$sum": 1
      }, 
      "jlh": {
        "$sum": "$Jumlah"
      }
    }
  }
]')

hadir <- db2$aggregate('[
  {
    "$group": {
      "_id": {
        "Kategori": "$Kategori", 
        "Status": "$Tindakan"
      }, 
      "bil": {
        "$sum": 1
      }
    }
  }
]')

# jlh & menu
menu <- db2$aggregate('[{
  "$project": {
    "id_": 0
   }
  }, {
   "$group": {
    "_id": "$Menu",
    "jlh": {
     "$sum": 1
    }
   }
  }]')


# ipu <- db$find('{}')
# calc kpi ----
kpi <- db$find('{}')

jlh_taja <- db1$aggregate('[{
    "$match": {
      "Tindakan": "Bayaran diterima"
    }
  }, {
    "$group": {
      "_id": "",
      "jlh": {
        "$sum": "$Jumlah"
      }
    }
  }]')

jlh_hadir <- db2$aggregate('[{
   "$match": {
    "Tindakan": "Bayaran diterima"
   }
  }, {
   "$count": "Nama"
  }]')

ipu <- kpi %>% mutate("Tajaan" = (jlh_taja$jlh - taja_min)/(taja_sasar - taja_min),
                      "Kehadiran" = (jlh_hadir$Nama - hadir_min)/(hadir_sasar - hadir_min))

# carta ----
names(tajaan) <- c("Tajaan", "Bil", "Jlh")
names(hadir) <- c("Hadir", "Bil")
names(menu) <- c("Menu", "jlh")

c1 <- ggplot(aes(Tajaan$entiti, y=Bil, fill=Tajaan$status), data=tajaan) + geom_bar(stat="identity") +
  geom_text(aes(label = Bil), position = position_stack(vjust = 0.5), colour = "blue") +
  scale_fill_manual(values = c("green", "gold")) +
  coord_flip()

c2 <- ggplot(aes(Hadir$Kategori, y=Bil, fill=Hadir$Status), data=hadir) + geom_bar(stat="identity") +
  geom_text(aes(label = Bil), position = position_stack(vjust = 0.5), colour = "blue") +
  scale_fill_manual(values = c("green", "red", "gold")) +
  coord_flip()

c3 <- ggplot(aes(Menu, y=jlh, fill=Menu), data=menu) + geom_bar(stat="identity") +
  geom_text(aes(label = jlh), position = position_stack(vjust = 0.5), colour = "white") +
  scale_fill_manual(values = c("green", "red", "blue", "gold"))

fig <- plot_ly(
  domain = list(x = c(0, 1), y = c(0, 1)),
  value = ipu$Tajaan,
  title = list(text = "IPU Tajaan"),
  type = "indicator",
  mode = "gauge+number") 
fig <- fig %>%
  layout(margin = list(l=20,r=30))

fig


