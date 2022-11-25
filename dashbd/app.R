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
      menuItem("Indeks Prestasi Utama", tabName = "dashboard", icon = icon("signal", lib = "glyphicon")),
      menuItem("Carta", tabName = "carta", icon = icon("signal", lib = "glyphicon"))
    )
  ),
  
  body <- dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Indeks Prestasi Utama (IPU)"),
              box("Tajaan",gaugeOutput("tajaan")),
              box("Kehadiran",gaugeOutput("hadir")),
              box("Keseluruhan",gaugeOutput("all"))),
      tabItem(tabName = "carta",        
              h2("Carta Utama"),
              box("Tajaan", plotOutput("tj")),
              box("Kehadiran", plotOutput("hd"))
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
  
  ipu <- db$find('{}')
  
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
  
  # output$all = renderGauge({
  #   df <- score()
  #   rs <- 0.1*df$`KPI(%)`[1] + 0.3*df$`KPI(%)`[2] + 0.3*df$`KPI(%)`[3] + 0.3*df$`KPI(%)`[4]
  #   gauge(round(rs,1), 
  #         min = 0, 
  #         max = 100, 
  #         sectors = gaugeSectors(success = c(70, 100), 
  #                                warning = c(30, 69),
  #                                danger = c(0, 29)))
  # })
}

# Create Shiny app ----
shinyApp(ui, server)