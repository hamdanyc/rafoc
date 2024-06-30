# Load required libraries
library(mongolite)

# Connect to MongoDB
# Load db ----
MG_URL <- Sys.getenv("MG_URL")
db <- mongo(collection = "undi", db = "rafoc", url = MG_URL)

# Aggregate ----
ft <- db$aggregate('[
  {
    "$group": {
      "_id": "$selection", 
      "count": {
        "$count": {}
      }
    }
  }, {
    "$sort": {
      "count": -1
    }
  }
]')
