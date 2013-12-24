library(rgdal)
dir <- 'Counties/' # Directory of the shp file
file <- 'geonb_county-comte' # Name of the shp file

# "Multi": save in multiple parts. "Single": just one.
saveAs <- "Single"

# Inputs a file that has names and corresponding number key
namefile <- paste(dir, file, '.txt', sep='')
names <- read.csv(namefile, header=TRUE, sep=",", as.is=TRUE)

# Reads the shapefile and stores it in a SpatialPolygonDataFrame
polygon <- readOGR(dsn=dir, layer=file)

if (saveAs == "Multi") {
  # Splits the file up by KEYWORD and saves them as separate KML files
  for (i in 1:length(levels(polygon$KEYWORD))) {
    # Grabs the key for each subset, saves it in name, and
    # then replaces the key with the readable name
    name.key <- as.integer(levels(polygon$KEYWORD)[i])
    name <- names[names$KEY==name.key,'ENG_NAME']
    levels(polygon$KEYWORD)[i] <- name
    
    # Grabs each subset
    subset <- subset(polygon, polygon$KEYWORD==name)
    subsetWGS <- spTransform(subset, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
    
    # Save each subset as a separate KML file
    output.name <- paste(dir, "KML/", name, ".kml", sep="")
    writeOGR(subsetWGS, dsn=output.name, layer=name, driver="KML")
  }
} else {
    for (i in 1:length(levels(polygon$KEYWORD))) {
    # Grabs the key for each subset, saves it in name, and
    # then replaces the key with the readable name
    name.key <- as.integer(levels(polygon$KEYWORD)[i])
    name <- names[names$KEY==name.key,'ENG_NAME']
    levels(polygon$KEYWORD)[i] <- name
    }

    polygonWGS <- spTransform(polygon, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
    output.name <-  paste(dir, "KML/", "Filename.kml", sep="")
    writeOGR(polygonWGS, dsn=output.name, layer="Layer", driver="KML")
}