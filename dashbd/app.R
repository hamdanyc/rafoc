# app.R

# Init ----
library(shiny)
library(knitr)
library(dplyr)
library(flexdashboard)
library(shinydashboard)
library(mongolite)
library(ggplot2)
digits = 3

# extract db ----
# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data

con <- readLines(con=".url.txt")
db  <- mongolite::mongo(collection="ipu", db="rafoc", url=con)
db1 <- mongolite::mongo(collection="tajaan", db="rafoc", url=con)
db2 <- mongolite::mongo(collection="mmmt", db="rafoc", url=con)

# ui ----
ui <- dashboardPage(
  dashboardHeader(title = "Dashboard MMMT `22", titleWidth = 300),
  sidebar <- dashboardSidebar(
    sidebarMenu(
      menuItem("Indeks Prestasi Utama", tabName = "dashboard", icon = icon("dashboard", lib = "glyphicon")),
      menuItem("Carta Utama", tabName = "carta", icon = icon("signal", lib = "glyphicon"))
    )
  ),
  
  body <- dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Indeks Prestasi Utama (%)"),
              infoBoxOutput("tbox"),
              infoBoxOutput("otbox"),
              infoBoxOutput("hbox"),
              infoBoxOutput("ohbox"),
              box("Tajaan",gaugeOutput("tajaan")),
              box("Kehadiran",gaugeOutput("hadir")),
              box("Keseluruhan",gaugeOutput("all"))),
      tabItem(tabName = "carta",        
              h2("Carta Utama"),
              box("Tajaan", plotOutput("tj")),
              box("Kehadiran", plotOutput("hd")),
              box("Menu", plotOutput("mn"))
      )
    )
  )
)

# server ----
server <- function(input, output, clientData, session) {
  
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
  },{
    "$match": {
        "Tindakan": "Hadir"
    }
  },{
   "$group": {
    "_id": "$Menu",
    "jlh": {
     "$sum": 1
    }
   }
  }]')
  
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
    "Tindakan": "Hadir"
   }
  }, {
   "$count": "Nama"
  }]')
  
  ipu <- kpi %>% mutate("Tajaan" = (jlh_taja$jlh - taja_min)/(taja_sasar - jlh_taja$jlh)*100,
                        "Kehadiran" = (jlh_hadir$Nama - hadir_min)/(hadir_sasar - jlh_hadir$Nama)*100,
                        "Keseluruhan" = 0.5*Tajaan + 0.5*Kehadiran)
  # info box ----
  output$tbox <- renderInfoBox({
    infoBox(
      title="Tajaan",
      subtitle = "Sasaran",
      ipu$taja_sasar,
      icon = icon("usd", lib = "glyphicon")
    )
  })
  
  output$hbox <- renderInfoBox({
    infoBox(
      title="Kehadiran",
      subtitle = "Sasaran",
      ipu$hadir_sasar,
      color="green",
      icon = icon("user", lib = "glyphicon")
    )
  })
  
  output$otbox <- renderInfoBox({
    infoBox(
      title="Tajaan",
      subtitle = "Terima",
      jlh_taja$jlh,
      icon = icon("usd", lib = "glyphicon")
    )
  })
  
  output$ohbox <- renderInfoBox({
    infoBox(
      title="Kehadiran",
      subtitle = "Hadir",
      color="green",
      jlh_hadir$Nama,
      icon = icon("user", lib = "glyphicon")
    )
  })
  
  # dashboard ----
  output$tajaan = renderGauge({
    gauge(round(ipu$Tajaan,1), 
          min = 0, 
          max = 100, 
          sectors = gaugeSectors(success = c(70, 100), 
                                 warning = c(30, 69),
                                 danger = c(0, 29)))
  })
  
  output$hadir = renderGauge({
    gauge(round(ipu$Kehadiran,1), 
          min = 0, 
          max = 100, 
          sectors = gaugeSectors(success = c(70, 100), 
                                 warning = c(30, 69),
                                 danger = c(0, 29)))
  })
  
  output$all = renderGauge({
    gauge(round(ipu$Keseluruhan,1), 
          min = 0, 
          max = 100, 
          sectors = gaugeSectors(success = c(70, 100), 
                                 warning = c(30, 69),
                                 danger = c(0, 29)))
  })
  
  output$tj <- renderPlot({
    names(tajaan) <- c("Tajaan", "Bil", "Jlh")
    ggplot(aes(Tajaan$entiti, y=Bil, fill=Tajaan$status), data=tajaan) + geom_bar(stat="identity") +
      geom_text(aes(label = Bil), position = position_stack(vjust = 0.5), colour = "blue") +
      scale_fill_manual(values = c("green", "gold")) +
      coord_flip()
  })
  
  output$hd <- renderPlot({
    names(hadir) <- c("Hadir", "Bil")
    ggplot(aes(Hadir$Kategori, y=Bil, fill=Hadir$Status), data=hadir) + geom_bar(stat="identity") +
      geom_text(aes(label = Bil), position = position_stack(vjust = 0.5), colour = "blue") +
      scale_fill_manual(values = c("green", "red", "gold")) +
      coord_flip()
  })
  
  output$mn <- renderPlot({
    names(menu) <- c("Menu", "jlh")
    ggplot(aes(Menu, y=jlh, fill=Menu), data=menu) + geom_bar(stat="identity") +
      geom_text(aes(label = jlh), position = position_stack(vjust = 0.5), colour = "blue") +
      scale_fill_manual(values = c("green", "red", "cyan", "gold", "purple"))
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)