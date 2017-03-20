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
                                   leg_ttl_16 = sum(MNLEGTOTAL),
                                   r_ttl_16 = sum(MNLEGR),
                                   dfl_ttl_16 = sum(MNLEGDFL),
                                   pres_ttl_16 = sum(USPRSTOTAL),
                                   pres_r_ttl_16 = sum(USPRSR),
                                   pres_dfl_ttl_16 = sum(USPRSDFL)
)

# hardcode in 32B results
# http://electionresults.sos.state.mn.us/Results/StateRepresentative/103?districtid=418
# total votes = 7119
# R votes = 3789
# DFL votes = 3327

precinct2016.data.grp$leg_ttl_16[precinct2016.data.grp$DISTRICT == "32B"] <- 7119
precinct2016.data.grp$r_ttl_16[precinct2016.data.grp$DISTRICT == "32B"] <- 3789
precinct2016.data.grp$dfl_ttl_16[precinct2016.data.grp$DISTRICT == "32B"] <- 3327 

# get MN house vote percentage
precinct2016.data.grp$pct_r_16 <- round(precinct2016.data.grp$r_ttl_16 / precinct2016.data.grp$leg_ttl_16, 3)*100
precinct2016.data.grp$pct_dfl_16 <- round(precinct2016.data.grp$dfl_ttl_16 / precinct2016.data.grp$leg_ttl_16, 3)*100

# get pres vote percentage
precinct2016.data.grp$pct_pr_16 <- round(precinct2016.data.grp$pres_r_ttl_16 / precinct2016.data.grp$pres_ttl_16, 3)*100
precinct2016.data.grp$pct_pdfl_16 <- round(precinct2016.data.grp$pres_dfl_ttl_16 / precinct2016.data.grp$pres_ttl_16, 3)*100

# get margin of win
precinct2016.data.grp$mrg_16 <- round((precinct2016.data.grp$pct_dfl_16 - precinct2016.data.grp$pct_r_16),2)
precinct2016.data.grp$mrg_p16 <- round((precinct2016.data.grp$pct_pdfl_16 - precinct2016.data.grp$pct_pr_16),2)


# merge with shapefile 
mnlegdistricts.2016.data.merge <- merge(x=mnlegdistricts, y=precinct2016.data.grp, by=c("DISTRICT"), all.x = TRUE)

# Write out district shapefile
writeOGR(mnlegdistricts.2016.data.merge, "../results/", "mnlegdistricts-results-2016", driver="ESRI Shapefile")

