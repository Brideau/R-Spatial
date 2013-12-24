library(rgdal)
dir <- 'Places' # Directory of the shp file
file <- '1M_Place_Names_2009' # Name of the shp file

if (!file.exists(paste(dir, 'Converted', sep="/"))) {
  dir.create(paste(dir, '/Converted', sep="/"))
}

# "Multi": save in multiple parts. "Single": just one.
saveAs <- "Multi"
includeCoords <- "Y" # Y/N
external.name.file <- "N" # Y/N

# To see what outputs types are available, execute orgDrivers()
outputType <- "CSV"

if (external.name.file == "Y") {
  # Inputs a file that has names and corresponding number key
  namefile <- paste(dir, '/', file, '.txt', sep='')
  names <- read.csv(namefile, header=TRUE, sep=",", as.is=TRUE)
}

# Reads the shapefile and stores it in a SpatialPolygonDataFrame
polygon <- readOGR(dsn=dir, layer=file)

if (saveAs == "Multi") {
  # Splits the file up by KEYWORD and saves them as separate files
  for (i in 1:length(levels(polygon$PROV_EN))) {
    
    if (external.name.file == "Y") {
      # Grabs the key for each subset, saves it in name, and
      # then replaces the key with the readable name
      name.key <- as.integer(levels(polygon$PROV_EN)[i])
      name <- names[names$KEY==name.key,'ENG_NAME']
      levels(polygon$PROV_EN)[i] <- name
    } else {
      name <- levels(polygon$PROV_EN)[i]
    }
    
    # Grabs each subset
    subset <- subset(polygon, polygon$PROV_EN==name)
    subsetWGS <- spTransform(subset, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
    
    if (includeCoords == "Y") {
      subsetWGS@data$LONGITUDE <- subsetWGS@coords[,1]
      subsetWGS@data$LATITUDE <- subsetWGS@coords[,2]
    }
    
    # Save each subset as a separate file
    output.name <- paste(dir, "/Converted/", name, ".", tolower(outputType), sep="")
    writeOGR(subsetWGS, dsn=output.name, layer=name, driver=outputType)
  }
} else {
    if (external.name.file == "Y") {
      for (i in 1:length(levels(polygon$KEYWORD))) {
      # Grabs the key for each subset, saves it in name, and
      # then replaces the key with the readable name
      name.key <- as.integer(levels(polygon$KEYWORD)[i])
      name <- names[names$KEY==name.key,'ENG_NAME']
      levels(polygon$KEYWORD)[i] <- name
      }
    }

    polygonWGS <- spTransform(polygon, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
    
    if (includeCoords == "Y") {
      polygonWGS@data$LONGITUDE <- polygonWGS@coords[,1]
      polygonWGS@data$LATITUDE <- polygonWGS@coords[,2]
    }
    
    output.name <-  paste(dir, "/", file, ".", tolower(outputType), sep="")
    writeOGR(polygonWGS, dsn=output.name, layer="Layer", driver=outputType)
}