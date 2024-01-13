library(shiny)
library(googledrive)
library(mongolite)

# Replace with your MongoDB connection string
# con <- readLines(con="~/.url.txt")
# get MG_URL from environment variable
con <- Sys.getenv("MG_URL")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)

shinyServer(function(input, output) {
  
  # find the record
  df <- reactive({
    # output from query
    qry <- paste0('{"no_kp": "',input$no_kp,'"}')
    
    # Query data ----
    rs <- db$find(qry)
  })
  
  output$nama <- renderText({paste0("Nama: ",df()$nama)})
  output$alamat <- renderText({paste0("Alamat: ",df()$alamat_tetap1,", ",df()$alamat_tetap2)})
  output$foto <- renderText({paste0("Foto: ",df()$foto)})
  
  observeEvent(input$photo, {
    photo_file <- input$photo$datapath
    
    tryCatch({
      # Authenticate with Google Drive (if needed)
      drive_auth()

      # Upload photo to Google Drive
      # Get the desired folder ID (replace with your method)
      folder_id = "https://drive.google.com/drive/folders/1GEwLiA4Kj7Uhqh5L5N_EZcmA7jTg9sLu"  # Replace with actual folder ID
      
      # Upload to the specific folder
      file <- drive_upload(photo_file, name = basename(photo_file), path = as_id(folder_id))
      google_drive_link <- as_id(folder_id)  # Get the file ID or link
      
      qry <- paste0('{"no_kp": "',input$no_kp,'"}')
      db$update(qry, paste0("'",'{"$set": {foto: "', google_drive_link, '"}',"}'"))
      db$update(qry, '{"$set": {foto: "google_drive_link"}}')
    }, error = function(err) {
      output$upload_status <- renderText("Error:", err$message)
    })
  })
})
