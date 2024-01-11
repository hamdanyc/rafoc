library(shiny)
library(googledrive)
library(mongolite)

# Replace with your MongoDB connection string
con <- readLines(con="~/.url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)
# mongo_uri <- "mongodb://your_username:your_password@your_mongodb_host:your_mongodb_port/your_database_name"

shinyServer(function(input, output) {
  
  observeEvent(input$photo, {
    photo_file <- input$photo$datapath
    no_kp <- input$id  # Assuming you have an "id" input field in your UI
    
    tryCatch({
      # Authenticate with Google Drive (if needed)
      drive_auth()
      
      # Find or insert record in MongoDB
      # mongo_collection <- mongo(collection = "your_collection_name", url = mongo_uri)
      qry <- paste0('{"no_kp": "',no_kp,'"}')
      rs <- db$find(qry, fields='{"_id": 0, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
      # Upload photo to Google Drive
      # Get the desired folder ID (replace with your method)
      folder_id = "https://drive.google.com/drive/folders/1GEwLiA4Kj7Uhqh5L5N_EZcmA7jTg9sLu"  # Replace with actual folder ID
      
      # Upload to the specific folder
      file <- drive_upload(photo_file, name = basename(photo_file), path = as_id(folder_id))
      google_drive_link <- as_id(folder_id)  # Get the file ID or link
      
      if (nrow(rs) > 0) {
        # Record exists, get the name
        user_name <- rs$nama[[1]]
        address1 <- rs$alamat_tetap1[[1]]
        address2 <- rs$alamat_tetap2[[1]]
        output$upload_status <- renderText("Record found! Name:", user_name)
      } else {
        # Record doesn't exist, insert new record
        mongo_collection$insert(list(
          id = user_id,
          address = input$address,  # Assuming you have an "address" input field
          photo_link = google_drive_link
        ))
        output$upload_status <- renderText("New record inserted successfully!")
      }
    }, error = function(err) {
      output$upload_status <- renderText("Error:", err$message)
    })
  })
})
