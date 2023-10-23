# db_qry_fun.R

# function to query database ----
function(field, pattern) {
  pattern <- toupper(pattern)
  qry <- paste0('{"', field, '": {"$regex": "', pattern, '"}}')
  db$find(qry, fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
}

# convert to function qry by neg ----
qn <- function(negeri) {
  negeri <- toupper(negeri)
  db$find(paste0('{"$or": [{"alamat_tetap1": {"$regex": "', negeri, '"}}, {"alamat_tetap2": {"$regex": "', negeri, '"}}]}'), 
          fields='{"_id": 0, "no_tentera": 1, "nama": 1, "no_kp": 1, 
          "alamat_tetap1": 1, "alamat_tetap2": 1, "pkt": 1}')
}