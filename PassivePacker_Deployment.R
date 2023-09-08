#Prepare deployment details for NCEI - Passive Packer
#Kourtney Burger

#Save Deployment Details and GPS points as .csv and save to folders within project

#required packages
library(here)
library(DBI)
library(RSQLite)
library(tidyverse)

#Import Deployment Details 
DepDir <- here('ADRIFT-Deployment-PassivePacker')
deployDetails <- read.csv("DeploymentDetails/CCES_DeploymentDetails.csv")

#Import PassivePacker sqlite Data Table
#db <- dbConnect(SQLite(), "PassivePacker_v.4.0.2-win64/database/packageData.sqlite")
#PP_DeploymentData <- dbReadTable(db, 'DEPLOYMENT_DATA')


#Set up Passive Packer data table
dd <- subset(deployDetails, select = c('Project', 'DeploymentID', 'Cruise', 
                                       'Platform', 'Type', 'Instrument_ID', 
                                       'Deployment_Date', 'Data_Start', 
                                       'Recovery_Date', 'Data_End'))

dd <- dd %>%
  add_column(ID = NA, SITE_OR_CRUISE = NA, PACKAGE_ID = NA, SOURCE_PATH = NA,
             DESTINATION_PATH = NA, METADATA_AUTHOR = 'Kourtney Burger', 
             META_AUTHOR_UUID = NA, PUBLICATION_DATE = NA, DEPLOYMENT_ALIAS = NA,
             SITE_ALIAS = NA, TITLE = NA, PURPOSE = NA, ABSTRACT = NA, 
             DATA_COMMENT = NA, TEMP_PATH = NA, BIO_PATH = NA, OTHER_PATH = NA,
             DOCS_PATH = NA, CALIBRATION_PATH = NA, CREATION_TIME = NA, 
             UPDATE_TIME = NA, USE = NA, SAMPLING_DETAILS = NA, 
             QUALITY_DETAILS = NA, SCIENTISTS = NA, SPONSERS = NA, FUNDERS = NA, 
             SENSORS = NA, DEPLOYMENT_DETAILS = NA, CALIBRATION_INFO = NA, 
             DATASET_INFO = NA, ANCILLARY_INFO = NA)

dd <- dd[, c(11,1,2,3,12,13,14,15,16,17,18,4,5,6,19,20,7,8,9,10,21,22,23,24,25,
             26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42)]

colnames(dd) <- c('ID','PROJECT','DEPLOYMENT_ID','SITE_CRUISE','SITE_OR_CRUISE',
                  'PACKAGE_ID','SOURCE_PATH','DESTINATION_PATH','METADATA_AUTHOR',
                  'META_AUTHOR_UUID','PUBLICATION_DATE','PLATFORM','INSTRUMENT_TYPE',
                  'INSTRUMENT_ID','DEPLOYMENT_ALIAS','SITE_ALIAS','DEPLOY_TIME',
                  'AUDIO_START_TIME','RECOVER_TIME','AUDIO_END_TIME','TITLE',
                  'PURPOSE','ABSTRACT','DATA_COMMENT','TEMP_PATH','BIO_PATH',
                  'OTHER_PATH','DOCS_PATH','CALIBRATION_PATH','CREATION_TIME',
                  'UPDATE_TIME','USE','SAMPLING_DETAILS','QUALITY_DETAILS',
                  'SCIENTISTS','SPONSORS','FUNDERS','SENSORS','DEPLOYMENT_DETAILS',
                  'CALIBRATION_INFO','DATASET_INFO','ANCILLARY_INFO')   

dd$PROJECT <- paste('SWFSC_',dd$PROJECT)
dd$PROJECT <- gsub(" ","",dd$PROJECT)

dd$PACKAGE_ID <- paste(dd$PROJECT,'_',dd$SITE_CRUISE,'_',dd$DEPLOYMENT_ID)
dd$PACKAGE_ID <- gsub(" ","",dd$PACKAGE_ID)

  #Change soundtrap names
dd[dd == "ST640"] <- "SoundTrap 640"
dd[dd == "ST4300HF"] <- "SoundTrap 4300 HF"
dd[dd == "ST300"] <- "SoundTrap 300"
dd[dd == "ST4300"] <- "SoundTrap 4300"
dd[dd == "ST500HF"] <- "SoundTrap 500 HF"
dd[dd == "ST300HF"] <- "SoundTrap 300 HF"

#The following info will stay the same for each project (CCES, PASCAL, ADRIFT)
dd["TITLE"][is.na(dd["TITLE"])] <- 'California Current Ecosystem Survey'
dd["PURPOSE"][is.na(dd["PURPOSE"])] <- 'From Report'
dd["ABSTRACT"][is.na(dd["ABSTRACT"])] <- 'From Report'


#Write dataframe to existing database
con <- dbConnect(SQLite(), "PassivePacker_v.4.0.2-win64/database/packageData.sqlite")
dbWriteTable(con, 'DEPLOYMENT_DATA', dd, overwrite = TRUE)
dbDisconnect(con)

db <- dbConnect(SQLite(), "PassivePacker_v.4.0.2-win64/database/packageData.sqlite")
PP_DeploymentData <- dbReadTable(db, 'DEPLOYMENT_DATA')

