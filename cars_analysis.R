setwd("C:/Users/jpierzchlewicz/cars")

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
cars$country_of_origin[cars$country_of_origin == "Włochy"] <- "Italy"

cars <- read.csv("otomoto_with_coord.csv", encoding="UTF-8")

# Map
library(rworldmap)
library(ggmap)
newmap <- getMap(resolution = "medium")
poland.limits <- geocode(c("Poland"))
plot(newmap, xlim=c(poland.limits$lon-3,poland.limits$lon+3), ylim=c(poland.limits$lat-3,poland.limits$lat+3), asp=1)
# car_locations <- geocode(as.vector(cars$location), source="google")
points(car_locations$lon,car_locations$lat, col="red")

cars$lat <- car_locations$lat
cars$lng <- car_locations$lng
write.csv(cars, "otomoto_with_coord.csv")

# Bar plot of country of origin
barplot(table(cars$country_of_origin))

hist(cars$mileage[cars$mileage < 500000], breaks=20)

hist(cars$price, breaks=15)

library(lattice)
price_vs_year <- aggregate(cars$price, list(cars$production_year), mean)
barchart(Group.1~x, data=prive_vs_year)


poland <- get_map(location = 'Poland', zoom = 6)
p <- ggmap(poland)
p + geom_point(data=cars, aes(x=lon, y=lat),size=5)
p + geom_tile(data = cars, aes(x = lon, y = lat, alpha = price), fill = 'red')

loc_price_fit <- lm(price ~ lat + lon, data=cars)

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

library(FNN)
loc_price_fit <- knn.reg(cars[,c("lat","lon")], y=cars$price, test=df, k=10, algorithm="brute")


p + geom_tile(data = df, aes(x = lon, y = lat, alpha = loc_price_fit$pred), fill = 'red')
p + geom_point(data = cars, aes(x = lon, y = lat, alpha = cars$price), color = 'red', size=5)