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
                                   leg_ttl_12 = sum(MNLEGTOTAL),
                                   r_ttl_12 = sum(MNLEGR),
                                   dfl_ttl_12 = sum(MNLEGDFL),
                                   pres_ttl_12 = sum(USPRSTOTAL),
                                   pres_r_ttl_12 = sum(USPRSR),
                                   pres_dfl_ttl_12 = sum(USPRSDFL)
)
                                  
# get MN house vote percentage
precinct2012.data.grp$pct_r_12 <- round(precinct2012.data.grp$r_ttl_12 / precinct2012.data.grp$leg_ttl_12, 3)*100
precinct2012.data.grp$pct_dfl_12 <- round(precinct2012.data.grp$dfl_ttl_12 / precinct2012.data.grp$leg_ttl_12, 3)*100

# get pres vote percentage
precinct2012.data.grp$pct_pr_12 <- round(precinct2012.data.grp$pres_r_ttl_12 / precinct2012.data.grp$pres_ttl_12, 3)*100
precinct2012.data.grp$pct_pdfl_12 <- round(precinct2012.data.grp$pres_dfl_ttl_12 / precinct2012.data.grp$pres_ttl_12, 3)*100

# get margin of win
precinct2012.data.grp$mrg_12 <- round((precinct2012.data.grp$pct_dfl_12 - precinct2012.data.grp$pct_r_12),2)
precinct2012.data.grp$mrg_p12 <- round((precinct2012.data.grp$pct_pdfl_12 - precinct2012.data.grp$pct_pr_12),2)

mnlegdistricts.2012.data.merge <- merge(x=mnlegdistricts, y=precinct2012.data.grp, by=c("DISTRICT"), all.x = TRUE)

# Write out district shapefile
writeOGR(mnlegdistricts.2012.data.merge, "../results/", "mnlegdistricts-results-2012", driver="ESRI Shapefile")

