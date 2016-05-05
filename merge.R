# this clears the space
rm(list = ls())

# libaries (some of these aren't needed)
library("ggmap")
library("rgeos")
library("maptools")
library("RColorBrewer")
library("rgdal")
library("leafletR")
library("ggplot2")
library("magrittr")
library("RJSONIO")

# notes

## http://magic.lib.uconn.edu/connecticut_data.html

setwd("")
# read achievement gap data
gap.data <- read.csv(file="", header=T)

# read school district polygons
setwd("")
districts <- readOGR(dsn=".", layer="")

setwd("")
path <- ""

plot(districts)

## beautiful!!

# merge gap data with shapefile
gap <- merge(districts, gap.data, by='Dist_Code', duplicateGeoms=TRUE, all.x=FALSE)

print(gap@data$ELA_White_Black)

subdat <- gap@data[, c("Dist_Code", "TOWN.x", "ELA_District", "ELA_State_District", "ELA_District_HN", "ELA_White_Black", "ELA_White_Hispanic", "ELA_District_EL", "ELA_District_SWD",
                       "Math_District", "Math_State_District", "Math_District_HN","Math_White_Black", "Math_White_Hispanic", "Math_District_EL", "Math_District_SWD")]

gap <- gSimplify(gap, tol=0.01, topologyPreserve=TRUE)

gap <- SpatialPolygonsDataFrame(gap, data=subdat, match.ID=FALSE)

geojson_file2 <-"gaps.json"

writeOGR(gap, geojson_file2, layer="geojson", driver="GeoJSON")

# https://github.com/rhodges/leaflet-choropleth-example/blob/master/site/choropleth-example.html

