# mm_dashbd.R

# init ----
library(kableExtra)
library(mongolite)
library(dplyr)
library(ggplot2)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data

con <- readLines(con=".url.txt")
db1 <- mongolite::mongo(collection="tajaan", db="rafoc", url=con)
db2 <- mongolite::mongo(collection="mmmt", db="rafoc", url=con)

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

# carta ----
names(tajaan) <- c("Tajaan", "Bil", "Jlh")
names(hadir) <- c("Hadir", "Bil")

c1 <- ggplot(aes(Tajaan$entiti, y=Bil, fill=Tajaan$status), data=tajaan) + geom_bar(stat="identity") +
  geom_text(aes(label = Bil), position = position_stack(vjust = 0.5), colour = "blue") +
  scale_fill_manual(values = c("green", "gold")) +
  coord_flip()

c2 <- ggplot(aes(Hadir$Kategori, y=Bil, fill=Hadir$Status), data=hadir) + geom_bar(stat="identity") +
  geom_text(aes(label = Bil), position = position_stack(vjust = 0.5), colour = "blue") +
  scale_fill_manual(values = c("green", "red", "gold")) +
  coord_flip()

