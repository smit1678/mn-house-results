# ***************
# 2016 MN House Results
# ***************

#x <- c("XLConnect", "rgdal", "rgeos", "raster", "maptools", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "spatstat", "gridExtra", "GISTools") # list of required packages
x <- c("rgdal", "rgeos", "raster", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "GISTools") # list of required packages
#install.packages(x) # installs all packages
lapply(x, library, character.only = TRUE) # load the required packages
rm(x)

## Read in 2016 data
precinct2016 <- readOGR(dsn="../source-data/elec2016/elec2016.shp", "elec2016")
mnlegdistricts <- readOGR(dsn="../source-data/L2012-1/L2012-1.shp", "L2012-1")

# extract data from shapefile
precinct2016.data <- precinct2016@data
# clean up data
precinct2016.data <- rename(precinct2016.data, DISTRICT = MNLEGDIST)
precinct2016.data$DISTRICT <- sprintf("%03s",precinct2016.data$DISTRICT)

# group by mn leg district and sum vote totals
precinct2016.data.grp <- group_by(precinct2016.data, DISTRICT)
precinct2016.data.grp <- summarise(precinct2016.data.grp, 
                                   pres_total = sum(MNLEGTOTAL),
                                   r_total = sum(MNLEGR),
                                   dfl_total = sum(MNLEGDFL)
                                   )
# get party vote percentage
precinct2016.data.grp$pct_r <- round(precinct2016.data.grp$r_total / precinct2016.data.grp$pres_total, 3)
precinct2016.data.grp$pct_dfl <- round(precinct2016.data.grp$dfl_total / precinct2016.data.grp$pres_total, 3)

# get margin of win
precinct2016.data.grp$diff <- (precinct2016.data.grp$pct_r - precinct2016.data.grp$pct_dfl)*100

mnlegdistricts.data.merge <- merge(x=mnlegdistricts, y=precinct2016.data.grp, by=c("DISTRICT"), all.x = TRUE)

# Write out district shapefile
writeOGR(mnlegdistricts.data.merge, "../results/", "mnlegdistricts-results-2016", driver="ESRI Shapefile")

