# ***************
# 2010 MN House Results
# ***************

#x <- c("XLConnect", "rgdal", "rgeos", "raster", "maptools", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "spatstat", "gridExtra", "GISTools") # list of required packages
x <- c("rgdal", "rgeos", "raster", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "GISTools") # list of required packages
#install.packages(x) # installs all packages
lapply(x, library, character.only = TRUE) # load the required packages
rm(x)

## Read in 2010 data
precinct2010 <- readOGR(dsn="../source-data/elec2010/elec2010.shp", "elec2010")
mnlegdistricts <- readOGR(dsn="../source-data/L2012-1/L2012-1.shp", "L2012-1")

# extract data from shapefile
precinct2010.data <- precinct2010@data
# clean up data
precinct2010.data <- rename(precinct2010.data, DISTRICT_oth = DISTRICT)
precinct2010.data <- rename(precinct2010.data, DISTRICT = LEG)

# group by mn leg district and sum vote totals
precinct2010.data.grp <- group_by(precinct2010.data, DISTRICT)
precinct2010.data.grp <- summarise(precinct2010.data.grp, 
                                   pres_total = sum(MNLEGTOT),
                                   r_total = sum(MNLEGR),
                                   dfl_total = sum(MNLEGDFL)
)
# get party vote percentage
precinct2010.data.grp$pct_r <- round(precinct2010.data.grp$r_total / precinct2010.data.grp$pres_total, 3)
precinct2010.data.grp$pct_dfl <- round(precinct2010.data.grp$dfl_total / precinct2010.data.grp$pres_total, 3)

# get margin of win
precinct2010.data.grp$diff <- (precinct2010.data.grp$pct_r - precinct2010.data.grp$pct_dfl)*100

mnlegdistricts.data.merge <- merge(x=mnlegdistricts, y=precinct2010.data.grp, by=c("DISTRICT"), all.x = TRUE)

# Write out district shapefile
writeOGR(mnlegdistricts.data.merge, "../results/", "mnlegdistricts-results-2010", driver="ESRI Shapefile")

