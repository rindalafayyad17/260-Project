library(tidyverse)
library(dplyr)
library(stringr)

dat <- read.csv(file = "wages.csv", header = TRUE)

sub <- dat %>% select(AREA_TITLE, OCC_TITLE, H_MEAN, A_MEAN)

sub <- sub %>% separate(AREA_TITLE, c("City", "State"), sep = ",")

cities <- c("Los Angeles", "New York", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "San Francisco", "Indianapolis", "Seattle", "Denver", "Boston", "El Paso", "Washington", "Nashville", "Detroit", "Oklahoma City", "Portland", "Las Vegas", "Memphis", "Louisville", "Baltimore", "Milwaukee", "Albuquerque", "Tucson", "Fresno", "Mesa", "Sacramento", "Atlanta", "Kansas City", "Colorado Springs", "Omaha", "Raleigh", "Miami", "Long Beach", "Virginia Beach", "Oakland", "Minneapolis", "Tulsa", "Tampa", "Arlington", "New Orleans" )

sep_cities <- sub %>% separate(City, c("City1", "City2", "City3"), sep = "-")

df1 <- sep_cities %>% 
  select(- c("City2", "City3"))
colnames(df1)[1] <- "City"

df2 <- sep_cities %>%
  select(-c("City1", "City3"))
colnames(df2)[1] <- "City"

df3 <- sep_cities %>%
  select(-c("City1", "City2"))
colnames(df3)[1] <- "City"

one_city <- rbind(df1, df2, df3)
one_city$City[one_city$City == "Louisville/Jefferson County"] <- "Louisville"

final <- one_city %>% filter(City %in% cities) %>% select(-State)

length(unique(final$City))
not_included <- ! (cities %in% limited$City)
cities[not_included]
#all the cities are included in the final dataset

colnames(final) <- c("City", "Occupation", "Hourly Wage", "Annual Wage")

final$`Hourly Wage`[final$`Hourly Wage` == "*"] <- NA
final$`Annual Wage`[final$`Annual Wage` == "*"] <- NA
final$`Hourly Wage`[final$`Hourly Wage` == "#"] <- ">100"
final$`Annual Wage`[final$`Annual Wage` == "#"] <- ">208000"

View(final)

write.csv(final,"C:/Users/Rindala/Desktop/Harvard/FALL 2021/BST 260\\wagesnew.csv", row.names = FALSE)
