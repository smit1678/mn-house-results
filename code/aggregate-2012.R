# ***************
# 2012 MN House Results
# ***************

#x <- c("XLConnect", "rgdal", "rgeos", "raster", "maptools", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "spatstat", "gridExtra", "GISTools") # list of required packages
x <- c("rgdal", "rgeos", "raster", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "GISTools") # list of required packages
#install.packages(x) # installs all packages
lapply(x, library, character.only = TRUE) # load the required packages
rm(x)

## Read in 2016 data
precinct2012 <- readOGR(dsn="../source-data/elec2012/elect2012.shp", "elect2012")
mnlegdistricts <- readOGR(dsn="../source-data/L2012-1/L2012-1.shp", "L2012-1")

# extract data from shapefile
precinct2012.data <- precinct2012@data
# clean up data
precinct2012.data <- rename(precinct2012.data, DISTRICT = MNLEGDIST)
precinct2012.data$DISTRICT <- sprintf("%03s",precinct2012.data$DISTRICT)

# group by mn leg district and sum vote totals
precinct2012.data.grp <- group_by(precinct2012.data, DISTRICT)
precinct2012.data.grp <- summarise(precinct2012.data.grp, 
                                   pres_total = sum(MNLEGTOTAL),
                                   r_total = sum(MNLEGR),
                                   dfl_total = sum(MNLEGDFL)
)
# get party vote percentage
precinct2012.data.grp$pct_r <- round(precinct2012.data.grp$r_total / precinct2012.data.grp$pres_total, 3)
precinct2012.data.grp$pct_dfl <- round(precinct2012.data.grp$dfl_total / precinct2012.data.grp$pres_total, 3)

# get margin of win
precinct2012.data.grp$diff <- (precinct2012.data.grp$pct_r - precinct2012.data.grp$pct_dfl)*100

mnlegdistricts.data.merge <- merge(x=mnlegdistricts, y=precinct2012.data.grp, by=c("DISTRICT"), all.x = TRUE)

# Write out district shapefile
writeOGR(mnlegdistricts.data.merge, "../results/", "mnlegdistricts-results-2012", driver="ESRI Shapefile")

