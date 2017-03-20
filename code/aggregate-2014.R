# ***************
# 2016 MN House Results
# ***************

#x <- c("XLConnect", "rgdal", "rgeos", "raster", "maptools", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "spatstat", "gridExtra", "GISTools") # list of required packages
x <- c("rgdal", "rgeos", "raster", "reshape", "dplyr", "tidyr", "lubridate", "ggplot2", "ggmap", "GISTools") # list of required packages
#install.packages(x) # installs all packages
lapply(x, library, character.only = TRUE) # load the required packages
rm(x)

## Read in 2016 data
precinct2014 <- readOGR(dsn="../source-data/elec2014/vtd2014general_officialresults.shp", "vtd2014general_officialresults")
mnlegdistricts <- readOGR(dsn="../source-data/L2012-1/L2012-1.shp", "L2012-1")

# extract data from shapefile
precinct2014.data <- precinct2014@data
# clean up data
precinct2014.data <- rename(precinct2014.data, DISTRICT = MNLEGDIST)
precinct2014.data$DISTRICT <- sprintf("%03s",precinct2014.data$DISTRICT)

# group by mn leg district and sum vote totals
precinct2014.data.grp <- group_by(precinct2014.data, DISTRICT)
precinct2014.data.grp <- summarise(precinct2014.data.grp, 
                                   leg_ttl_14 = sum(MNLEGTOTAL),
                                   r_ttl_14 = sum(MNLEGR),
                                   dfl_ttl_14 = sum(MNLEGDFL)
                                   )
# get party vote percentage
precinct2014.data.grp$pct_r_14 <- round(precinct2014.data.grp$r_ttl_14 / precinct2014.data.grp$leg_ttl_14, 3)*100
precinct2014.data.grp$pct_dfl_14 <- round(precinct2014.data.grp$dfl_ttl_14 / precinct2014.data.grp$leg_ttl_14, 3)*100

# get margin of win
precinct2014.data.grp$mrg_14 <- round((precinct2014.data.grp$pct_dfl_14 - precinct2014.data.grp$pct_r_14),2)

mnlegdistricts.2014.data.merge <- merge(x=mnlegdistricts, y=precinct2014.data.grp, by=c("DISTRICT"), all.x = TRUE)

# Write out district shapefile
writeOGR(mnlegdistricts.2014.data.merge, "../results/", "mnlegdistricts-results-2014", driver="ESRI Shapefile")

