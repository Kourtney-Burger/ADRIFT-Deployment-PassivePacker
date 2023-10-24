# Passive Packer Table without JSON strings 

# Required Packages ----
library(here)
library(DBI)
library(RSQLite)
library(tidyverse)
library(rjson)

# Set Directory ----
DepDir <- here('ADRIFT-Deployment-PassivePacker')

# IMPORT & PREP DATA ----
## Import Deployment Details ----
deployDetails <- read.csv("DeploymentDetails/CCES_DeploymentDetails.csv")

## Import Passive Packer data table ----
db <- dbConnect(SQLite(), "PassivePacker_v.4.0.3-win64/database/packageData.sqlite")
ppdt <- dbReadTable(db, "DEPLOYMENT_DATA")
dbDisconnect(db)

## Prepare data to append to Passive Packer table ----

### Subset data ----
dd <- subset(deployDetails, select = c('Project', 'DeploymentID', 'Cruise'))

### Add reqiured columns ----
dd <- dd %>%
  add_column(ID = NA, SITE_OR_CRUISE = NA, PACKAGE_ID = NA, SOURCE_PATH = NA,
             DESTINATION_PATH = NA, METADATA_AUTHOR = 'Kourtney Burger', 
             META_AUTHOR_UUID = NA, PUBLICATION_DATE = NA, PLATFORM = NA, 
             INSTRUMENT_TYPE = NA, INSTRUMENT_ID = NA, DEPLOYMENT_ALIAS = NA,
             SITE_ALIAS = NA, DEPLOY_TIME = NA, AUDIO_START_TIME = NA,
             RECOVER_TIME =NA, AUDIO_END_TIME = NA, TITLE = "California Current Ecosystems Survey - Passive Acoustics Survey", 
             PURPOSE = "From Report", ABSTRACT = "From Report", DATA_COMMENT = NA, 
             TEMP_PATH = NA, BIO_PATH = NA, OTHER_PATH = NA, DOCS_PATH = NA, 
             CALIBRATION_PATH = NA, CREATION_TIME = NA, UPDATE_TIME = NA, 
             USE = 'Y', SAMPLING_DETAILS = NA, QUALITY_DETAILS = NA, 
             SCIENTISTS = NA, SPONSERS = NA, FUNDERS = NA, SENSORS = NA, 
             DEPLOYMENT_DETAILS = NA, CALIBRATION_INFO = NA, DATASET_INFO = NA, 
             ANCILLARY_INFO = NA)

### Reorder and rename columns ----
dd <- dd[, c(4,1,2,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,
             26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42)]

colnames(dd) <- c('ID','PROJECT','DEPLOYMENT_ID','SITE_CRUISE','SITE_OR_CRUISE',
                  'PACKAGE_ID','SOURCE_PATH','DESTINATION_PATH','METADATA_AUTHOR',
                  'META_AUTHOR_UUID','PUBLICATION_DATE','PLATFORM',
                  'INSTRUMENT_TYPE', 'INSTRUMENT_ID','DEPLOYMENT_ALIAS',
                  'SITE_ALIAS','DEPLOY_TIME', 'AUDIO_START_TIME','RECOVER_TIME',
                  'AUDIO_END_TIME','TITLE','PURPOSE','ABSTRACT','DATA_COMMENT',
                  'TEMP_PATH','BIO_PATH','OTHER_PATH','DOCS_PATH',
                  'CALIBRATION_PATH','CREATION_TIME','UPDATE_TIME','USE',
                  'SAMPLING_DETAILS','QUALITY_DETAILS','SCIENTISTS','SPONSORS',
                  'FUNDERS','SENSORS','DEPLOYMENT_DETAILS','CALIBRATION_INFO',
                  'DATASET_INFO','ANCILLARY_INFO') 

### Add ID Number (Primary Key) ----
num_rows = nrow(dd)
dd$ID <- c(1:num_rows)

### Fix project and package_id fields ----
#(combine columns and remove spaces)
dd$PROJECT <- paste('SWFSC-',dd$PROJECT)
dd$PACKAGE_ID <- paste(dd$PROJECT,'_',dd$SITE_CRUISE,'_',dd$DEPLOYMENT_ID)
dd$PROJECT <- paste('["',dd$PROJECT,'"]')
dd$PROJECT <- gsub(" ","",dd$PROJECT)
dd$PACKAGE_ID <- gsub(" ","",dd$PACKAGE_ID)

# Append final data table ----
con <- dbConnect(SQLite(), "PassivePacker_v.4.0.3-win64/database/packageData.sqlite")
dbAppendTable(con, "DEPLOYMENT_DATA", dd)
PP_DeploymentData <- dbReadTable(con, 'DEPLOYMENT_DATA')
dbDisconnect(con)

