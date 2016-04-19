# this clears the space
rm(list = ls())

# libaries
library("ggmap")
library("rgeos")
library("maptools")
library("RColorBrewer")
library("rgdal")
library("leafletR")
library("ggplot2")
library("magrittr")

# notes

## http://magic.lib.uconn.edu/connecticut_data.html

setwd("")
# read achievement gap data
gap.data <- read.csv(file="", header=T)
gap.only <- gap.data[ which(gap.data$ELA_White_Black != 'NA'), ]

# read school district polygons
setwd("")
districts <- readOGR(dsn=".", layer="elementaryschooldistrictct_37800_0000_2008_s100_trinity_1_shp_wgs84")

setwd("")
path <- ""

plot(districts)

## beautiful!!

# merge gap data with shapefile
gap <- merge(districts, gap.only, by='Dist_Code', duplicateGeoms=TRUE, all.x=FALSE)

print(gap@data$ELA_White_Black)
ela_w_b <- gap@data$ELA_White_Black

p <- colorRampPalette(brewer.pal(8,"OrRd"))(length(ela_w_b))
palette(p)

cols <- (ela_w_b - min(ela_w_b))/diff(range(ela_w_b))*(length(ela_w_b))
plot(gap, col=cols)


## lovely!!!!

## now for interactivity???? 
## http://zevross.com/blog/2014/04/11/using-r-to-quickly-create-an-interactive-online-map-using-the-leafletr-package/

subgap.df <- subset(gap.only, TOWN_NO > 0)

# removing "region" towns, or towns that have id = 0
subgap <- gap[gap$TOWN_NO.x > 0, ]

## Plainfield (Town 109) and Plainville (110) are in the same District code (109)

subgap.df <- subset(subgap.df, Dist_Code != 109)
subgap <- subgap[subgap$Dist_Code != 109, ]

# merging the files
subgap <- merge(subgap, subgap.df, by='Dist_Code', duplicateGeoms=FALSE, all.x=FALSE)

subdat_subgap <- subgap@data[,c("Dist_Code", "TOWN.x", "ELA_White_Black.x")]

subgap <- gSimplify(subgap, tol=0.01, topologyPreserve=TRUE)

subgap <- SpatialPolygonsDataFrame(subgap, data=subdat_subgap, match.ID=FALSE)

geojson_file <-"C:/Users/Jessica/Dropbox (CCER)/Analysis/Achievement Gap/Map/ela_w_b.json"

writeOGR(subgap, geojson_file, layer="geojson", driver="GeoJSON")

#pal <- colorQuantile("OrRd", NULL, n=5)

#popup <- paste0("<strong>District: </strong>",
#                subgap$TOWN.x,
#                "<br><strong>White-Black Achievement Gap, ELA: </strong>",
#                subgap$ELA_White_Black.x)

#leaflet(data = "C:/Users/Jessica/Dropbox (CCER)/Analysis/Achievement Gap/Map/ela_w_b.json") %>%
#  addPolygons(fillColor = ~pal(ELA_White_Black.x),
#              fillOpacity = 0.8,
#              color = "white",
#              weight = 1,
#              popup = popup)

# Google developers drag n drop: https://developers.google.com/maps/documentation/javascript/examples/layer-data-dragndrop

all <- merge(districts, gap.data, by='Dist_Code', duplicateGeoms=TRUE, all.x=FALSE)

# checking what's under the hood
print(rank(ela_w_b))

# ordering the list
ordered <- ela_w_b[order(ela_w_b)]

# merging into a color dataframe
ordered <- data.frame(ordered, p)

# renaming
ordered$ELA_White_Black <- ordered$ordered
ordered$ordered <- NULL
ordered$Color <- ordered$p
ordered$p <- NULL

# merging

with_color <- merge(all, ordered, by='ELA_White_Black', duplicateGeoms = TRUE, all.x=TRUE)

subdat_all <- with_color@data[, c("Dist_Code", "TOWN.x", "ELA_White_Black", "Color")]

with_color <- gSimplify(with_color, tol=0.01, topologyPreserve=TRUE)

with_color <- SpatialPolygonsDataFrame(with_color, data=subdat_all, match.ID=FALSE)

geojson_file2 <-""

writeOGR(with_color, geojson_file2, layer="geojson", driver="GeoJSON")

# http://leafletjs.com/examples/choropleth.html