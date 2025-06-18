# api.R
library(plumber)
library(dplyr)
library(tidyr)
library(jsonlite)


#* @get /wilcox
#* @param x comma-separated numbers
#* @param y comma-separated numbers
#* @serializer json
function(x = "1,2,3", y = "4,5,6") {
  x <- as.numeric(unlist(strsplit(x, ",")))
  y <- as.numeric(unlist(strsplit(y, ",")))
  list(p_value = wilcox.test(x, y, exact = FALSE)$p.value)
}

#* @get /totalghg
#* @param country query string
#* @serializer json
function(country="World") {
  df <- read.csv("data/total-greenhouse-gases/API_EN.GHG.ALL.MT.CE.AR5_DS2_en_csv_v2_6842.csv", stringsAsFactors = FALSE)

  df %>%
    filter(Country.Name == country) %>%
    pivot_longer(
      cols = matches("^X\\d{4}$"),
      names_to = "year",
      values_to = "value"
    ) %>%
    mutate(
      year = as.integer(sub("^X", "", year))
    ) %>%
    filter(year>=1970) %>% 
    select(year, value)
}

#* @get /countrylist
#* @serializer json
function () {
   df <- read.csv("data/total-greenhouse-gases/API_EN.GHG.ALL.MT.CE.AR5_DS2_en_csv_v2_6842.csv", stringsAsFactors = FALSE)
   df %>% 
    select(Country.Name) %>%
    distinct() %>%
    arrange(Country.Name)
}

#* @get /ghg-data
#* param country string
#* param year integer
#* @serializer json
function (country="World", input_year=2023) {
  get_value <- function(filepath, country, year_col) {
    df <- read.csv(filepath, stringsAsFactors = FALSE)
    names(df) <- gsub("^X", "", names(df))  # hapus 'X' di kolom tahun
    df %>%
      filter(Country.Name == country) %>%
      select(all_of(as.character(year_col))) %>%
      pull()
  }
  list(
    country = country,
    year = input_year,
    total = get_value("data/total-greenhouse-gases/API_EN.GHG.ALL.MT.CE.AR5_DS2_en_csv_v2_6842.csv", country, input_year),
    co2   = get_value("data/CO2-excluding-LULUCF/CO2-global.csv", country, input_year),
    ch4   = get_value("data/CH4-excluding-LULUCF/CH4-global.csv", country, input_year),
    n2o   = get_value("data/N2O-excluding-LULUCF/N2O-global.csv", country, input_year)
  )
}

#* @get /global-complete-data.json
#* @serializer contentType list(type="application/json")
function(){
  readChar("data/global_complete_data.json",
    nchars = file.info("data/global_complete_data.json")$size)
}

#* @get /countries.geojson
#* @serializer contentType list(type="application/json")
function() {
  readChar("data/countries.geojson",
    nchars = file.info("data/countries.geojson")$size)
}


#WRITE .JSON
files <- list(
  total = "data/total-greenhouse-gases/API_EN.GHG.ALL.MT.CE.AR5_DS2_en_csv_v2_6842.csv",
  co2   = "data/CO2-excluding-LULUCF/CO2-global.csv",
  ch4   = "data/CH4-excluding-LULUCF/CH4-global.csv",
  n2o   = "data/N2O-excluding-LULUCF/N2O-global.csv"
)

data_list <- list()

for(gas in names(files)) {
  df <- read.csv(files[[gas]], stringsAsFactors = FALSE)
  names(df) <- gsub("^X", "", names(df))            # hapus prefix “X” di nama kolom tahun
for (i in seq_len(nrow(df))) {
  code <- df$Country.Code[i]
  years <- setdiff(names(df), c("Country.Name","Country.Code"))
  for (yr in years) {
    val <- df[i, yr]
    data_list[[code]]               <- data_list[[code]] %||% list()
    data_list[[code]][[yr]]         <- data_list[[code]][[yr]] %||% list()
    data_list[[code]][[yr]][[gas]]  <- if (!is.na(val)) val
  }
}
  }

# tulis ke file
write_json(data_list,
           path   = "data/global_map_data.json",
           pretty = TRUE,
           auto_unbox = TRUE)
