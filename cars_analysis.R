
# Reads the CSV file and makes some alterations to the data
cars <- read.csv("otomoto.csv", encoding="UTF-8")
cars$mileage <- gsub(" km", "", cars$mileage)
cars$mileage <- gsub(" ", "", cars$mileage)
cars <- transform(cars, mileage = as.numeric(mileage))
cars$price <- gsub(" ", "", cars$price)
cars <- transform(cars, price = as.numeric(price))

cars$country_of_origin <- as.character(cars$country_of_origin)
cars$country_of_origin[cars$country_of_origin == "Belgia"] <- "Belgium"
cars$country_of_origin[cars$country_of_origin == "Polska"] <- "Poland"
cars$country_of_origin[cars$country_of_origin == "Francja"] <- "France"
cars$country_of_origin[cars$country_of_origin == "Holandia"] <- "Holland"
cars$country_of_origin[cars$country_of_origin == "Niemcy"] <- "Germany"
cars$country_of_origin[cars$country_of_origin == "Stany Zjednoczone"] <- "USA"
cars$country_of_origin[cars$country_of_origin == "Szwajcaria"] <- "Switzerland"
cars$country_of_origin[cars$country_of_origin == "Szwecja"] <- "Sweden"
cars$country_of_origin[cars$country_of_origin == "Włochy"] <- "Italy" # Might need to do it manually

# Download the offer location cooridinates using google API
library(ggmap)
car_locations <- geocode(as.vector(cars$location), source="google")

cars$lat <- car_locations$lat
cars$lng <- car_locations$lng

# Store altered data for future
write.csv(cars, "otomoto_with_coord.csv")

# Display the points on a map. Use price as Alpha (i.e. the lower the price the more transparent the point)
poland <- get_map(location = 'Poland', zoom = 6)
p <- ggmap(poland)
p + geom_point(data = cars, aes(x = lon, y = lat, alpha = cars$price), color = 'red', size=5)

# Some other graphs
barplot(table(cars$country_of_origin))

hist(cars$mileage[cars$mileage < 500000], breaks=20)

hist(cars$price, breaks=15)

# Calculates the boundaries and creates an evenly spaced tile list for heatmap display.
tiles <- list()
lat_min <- min(cars$lat)
lon_min <- min(cars$lon)
for (x in seq(4, (max(cars$lat)-lat_min), by=.1)){
  for (y in seq(0, (max(cars$lon)-lon_min)+1, by=.1)){
    tiles[[length(tiles)+1]] <- list(lat_min+x, lon_min+y)
  }
}
df <- do.call(rbind.data.frame, tiles)
colnames(df) <- c("lat", "lon")

# Using the kNN regression using brute-force algorithim. 
# The tests showed the best R2Pred for this set up for a reasonable speed, since the data set is relatively small. 
library(FNN)
loc_price_fit <- knn.reg(cars[,c("lat","lon")], y=cars$price, test=df, k=10, algorithm="brute")

# Display the headmap.
p + geom_tile(data = df, aes(x = lon, y = lat, alpha = loc_price_fit$pred), fill = 'red')