#Prepare deployment details for NCEI - Passive Packer

#GENERAL PLAN ----
# 1. Save Deployment Details and save to folders within project
# 2. Manipulate Deployment Details spreadsheet to match passive packer fields
# 3. Add additional passive packer fields
# 4. Connect to passive packer database and overwrite it 

## Taiki's suggestions: ----
#read in the original passive packer data table and append 
# deployment details data to maintain consistent data types 

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


# JSON STRINGS ----

## SAMPLING DETAILS COLUMN ----
  # data from deployDetails for list
#dd_sd <- subset(deployDetails, select = c('Data_Start', 'Data_End', 'ChannelNumber_1',
#                                          'SampleRate_kHz', 'RecordingDuration_m',
#                                          'RecordingInterval_m', 'ChannelNumber_2'))

# LIST COL NAME = DEPLOY DETAILS COL NAME
# 1
  # channel_start = Data_Start 
  # channel_end = Data_End 
  # sensor = ChannelNumber_1
  # sampling details
    #type: sample_rate_widget
      #value_1 = SampleRate_kHz
      #value_2 = 16 (should always be 16, variable not in deployment details)
      #checked = false (variable not in deployment details)
      #start = Data_Start 
      #end = Data_End   
    #type: duty_cycle_widget 
      #value_1 = RecordingDuration_m
      #value_2 = RecordingInterval_m
      #checked = false (variable not in deployment details)
      #start = Data_Start 
      #end = Data_End
# 2
  # channel_start = Data_Start 
  # channel_end = Data_End 
  # sensor = ChannelNumber_2
  # sampling details
    #type: sample_rate_widget
      #value_1 = SampleRate_kHz
      #value_2 = 16 (should always be 16, variable not in deployment details)
      #checked = false (variable not in deployment details)
      #start = Data_Start 
      #end = Data_End   
    #type: duty_cycle_widget 
      #value_1 = RecordingDuration_m
      #value_2 = RecordingInterval_m
      #checked = false (variable not in deployment details)
      #start = Data_Start 
      #end = Data_End



  # Copy text from database 
sdText <- '{"1": {"channel_start": "2018-11-22T08:28:24", 
                 "channel_end": "2018-12-03T00:49:11", 
                 "sensor": "1", 
                 "sampling details": [
                   {"type": "sample_rate_widget", 
                              "value_1": "576", 
                              "value_2": "16", 
                              "checked": false, 
                              "start": "2018-11-22T08:28:24", 
                              "end": "2018-12-03T00:49:11"}, 
                   {"type": "duty_cycle_widget", 
                              "value_1": "2", 
                              "value_2": "5", 
                              "checked": false, 
                              "start": "2018-11-22T08:28:24", 
                              "end": "2018-12-03T00:49:11"}]}, 
           "2": {"channel_start": "2018-11-22T08:28:24", 
                 "channel_end": "2018-12-03T00:49:11", 
                 "sensor": "2", 
                 "sampling details": [
                   {"type": "duty_cycle_widget", 
                              "value_1": "2", 
                              "value_2": "5", 
                              "checked": false, 
                              "start": "2018-11-22T08:28:24", 
                              "end": "2018-12-03T00:49:11"}, 
                   {"type": "sample_rate_widget", 
                              "value_1": "576", 
                              "value_2": "16", 
                              "checked": false, 
                              "start": "2018-11-22T08:28:24", 
                              "end": "2018-12-03T00:49:11"}]}}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
sdList <- fromJSON(sdText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonSD <- toJSON(sdList)
cat(jsonSD)



## QUALITY DETAILS COLUMN ----
# data from deployDetails for list
#dd_qd <- subset(deployDetails, select = c('Quality_Analyst', 'Quality_Category', 
#                                          'Quality_LowFreq', 'Quality_HighFreq',
#                                          'Data_Start', 'Data_End'))

# LIST COLUMN NAME  =   DEPLOY DETAILS COLUMN NAME
# analyst           =   Cory Hom-Weaver (constant)
# analyst_uuid      =   50ef109b-7ae0-40a9-b2a5-130d1cacb919 (constant for Cory)
# quality_details 
  # quality         =   'Quality_Category' (from deployment details)
  # low_freq        =   'Quality_LowFreq' (from deployment details)
  # high_freq       =   'Quality_HighFreq' (from deployment details)
  # start           =   'Data_Start' (from deployment details)
  # end             =   'Data_End' (from deployment details)
  # comments        =   "" (blank, no variable in deployment details)
  # channels        =   1 (constant, always 1 unless channel 2 was analyzed) 
# method            =   "" (blank, no variable in deployment details)
# objectives        =   "" (blank, no variable in deployment details)
# abstract          =   "" (blank, no variable in deployment details)

# Copy text from database 
qdText <- '{"analyst": "Cory Hom-Weaver", 
            "analyst_uuid": "50ef109b-7ae0-40a9-b2a5-130d1cacb919", 
            "quality_details": [
                                {"quality": "Good", 
                                 "low_freq": "20", 
                                 "high_freq": "576000", 
                                 "start": "2018-11-22T08:28:24", 
                                 "end": "2018-12-03T00:49:11", 
                                 "comments": "", 
                                 "channels": [1]}], 
            "method": "", 
            "objectives": "", 
            "abstract": ""}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
qdList <- fromJSON(qdText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,
view(qdList)

# And turn that list into a JSON text
jsonQD <- toJSON(qdList)
cat(jsonQD)



## SCIENTISTS COLUMN ----
# This will be the same for each drift within a project
# PASCAL - Shannon Rankin & Jennifer McCullough
# CCES - Shannon Rankin and Anne Simonis
# ADRIFT - Shannon Rankin & Chief sci from deployment details


# Copy text from database 
sciText <- '[{"name": "Anne Simonis", 
              "uuid": "3e9e1d2e-0fed-45d0-bc21-c388d4ea933a"},
             {"name": "Shannon Rankin", 
              "uuid": "c6a8953f-616b-4de1-99ce-3dd70e631dd5"}]'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
sciList <- fromJSON(sciText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonSCI <- toJSON(sciList)
cat(jsonSCI)


## SPONSERS COLUMN ----
# This will always be SWFSC unless another source organization did cruise/data 
# collection

# Copy text from database 
sponText <- '[{"name": "NOAA SWFSC", 
              "uuid": "918a8687-8b33-4f70-b550-79a5273866fa"}]'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
sponList <- fromJSON(sponText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonSPON <- toJSON(sponList)
cat(jsonSPON)



## FUNDERS COLUMN ----
# (REPEAT FOR ALL CCES) This will be the same for each drift within a project
# PASCAL - SWFSC, US Department of Interior, BOEM
# CCES - SWFSC, BOEM, US Navy Pacific Fleet
# ADRIFT - SWFSC, BOEM

# Copy text from database 
funText <- '[{"name": "NOAA SWFSC", 
              "uuid": "918a8687-8b33-4f70-b550-79a5273866fa"},
             {"name": "BOEM", 
              "uuid": "fee4d17a-a7dd-4f13-ade5-817b4f1fc86d"}, 
             {"name": "US Navy Pacific Fleet Environmental Readiness Division", 
              "uuid": "d246d0dc-b74b-4dc3-8d27-bdbb28b3e009"}]'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
funList <- fromJSON(funText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonFUN <- toJSON(funList)
cat(jsonFUN)



## SENSORS COLUMN ----
# A lot of this data has to come from the calibration sheet 
# For CCES, all calibration info is in 'CCES2018_CalibrationInfo.csv'
# For PASCAL, make spreadsheet from report
# For ADRIFT, use inventory spreadsheets

# data from calibration info spreadsheet
calInfo <- read.csv("Calibration Info/CCES2018_CalibrationInfo.csv")
#dd_sen <- subset(deployDetails, select = c())

# LIST COL NAME = DEPLOY DETAILS COL NAME
# 0  
  # type 
  # number 
  # id 
  # name 
  # pos_x 
  # pos_y 
  # pos_z 
  # value_1 
  # value_2 
  # description 
# 1 
  # type 
  # number
  # id
  # name 
  # pos_x 
  # pos_y 
  # pos_z 
  # value_1
  # value_2
  # description 
# 2
  # type 
  # number 
  # id 
  # name 
  # pos_x 
  # pos_y 
  # pos_z 
  # value_1 
  # value_2 
  # description 
# 3 
  # type 
  # number 
  # id
  # name 
  # pos_x 
  # pos_y 
  # pos_z 
  # value_1 
  # value_2 
  # description 
  # 2 SPOT sattelite GPS sensors

# Copy text from database 
senText <- '{"0": 
                {"type": "Audio Sensor", 
                 "number": "1", 
                 "id": "856048", 
                 "name": "HTI-92-WB\n", 
                 "pos_x": "", 
                 "pos_y": "", 
                 "pos_z": "-100", 
                 "value_1": "856048", 
                 "value_2": "", 
                 "description": ""}, 
              "1": 
                {"type": "Audio Sensor", 
                 "number": "2", 
                 "id": "856059", 
                 "name": "HTI-96-min", 
                 "pos_x": "", 
                 "pos_y": "", 
                 "pos_z": "-105", 
                 "value_1": "856059", 
                 "value_2": "", 
                 "description": ""}, 
              "2": 
                {"type": "Depth Sensor", 
                 "number": "3", 
                 "id": "Na", 
                 "name": "Sensus Ultra", 
                 "pos_x": "", 
                 "pos_y": "", 
                 "pos_z": "-100", 
                 "value_1": "", 
                 "value_2": "", 
                 "description": ""}, 
              "3": 
                {"type": "Other Sensor", 
                 "number": "4", 
                 "id": "A/B", 
                 "name": "SPOT GPS", 
                 "pos_x": "", 
                 "pos_y": "", 
                 "pos_z": "+1", 
                 "value_1": "GPS", 
                 "value_2": "", 
                 "description": 
                 "2 SPOT sattelite GPS sensors"}}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
senList <- fromJSON(senText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonSEN <- toJSON(senList)
cat(jsonSEN)



## DEPLOYMENT_DETAILS COLUMN ----

# LIST COL NAME = DEPLOY DETAILS COL NAME
# DEPLOY_TYPE = always 'Mobile Marine'
# SEA_AREA = always 'North Pacific Ocean'
# DEPLOY_SHIP = dependent on cruise, always 'R/V Ruben Lasker' for CCES
# FILES = Path to gps.csv file for each drift
# POSITION_DETAILS = always 'Satellite GPS'


# Copy text from database 
ddText <- '{"DEPLOY_TYPE": "Mobile Marine", 
            "SEA_AREA": "North Pacific Ocean", 
            "DEPLOY_SHIP": "R/V Ruben Lasker", 
            "FILES": "Z:/METADATA/CCES_2018/CCES_023/CCES_023_GPS/CCES_023_GPS.csv", 
            "POSITION_DETAILS": "Satellite gps"}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
ddList <- fromJSON(ddText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonDD <- toJSON(ddList)
cat(jsonDD)



## CALIBRATION_INFO COLUMN ----

# LIST COL NAME = DEPLOY DETAILS COL NAME
# CAL_STATE = always "Factory Calibrated" 
# CAL_DOCS_PATH = always "C:/Users/kourtney.burger/Documents/GitHub/ADRIFT-Deployment-PassivePacker/Calibration info", 
# SENSITIVITY =  leave blank 
# FREQUENCY = leave blank 
# GAIN = leave blank
# COMMENT = always "This dataset is composed of multichannel recorders with 
#                   different types of hydrophones, each with its own unique 
#                   sensitivity and frequency range. For the detailed calibration 
#                   information refer to the CCES2018_CalibrationInfo.csv 
#                   spreadsheet."


# Copy text from database 
calText <- '{"CAL_STATE": "Factory Calibrated", 
            "CAL_DOCS_PATH": "C:/Users/kourtney.burger/Documents/GitHub/ADRIFT-Deployment-PassivePacker/Calibration info", 
            "SENSITIVITY": "",  
            "FREQUENCY": "", 
            "GAIN": "", 
            "COMMENT": "This dataset is composed of multichannel recorders with different types of hydrophones, each with its own unique sensitivity and frequency range. For the detailed calibration information refer to the CCES2018_CalibrationInfo.csv spreadsheet."}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
calList <- fromJSON(calText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonCAL <- toJSON(calList)
cat(jsonCAL)



## DATASET_INFO COLUMN ----
# data from deployDetails for list
#dd_di <- subset(deployDetails, select = c('Type', 'Instrument_ID', 'Deployment_Date',
#                'Recovery_Date', 'Date_Start', 'Data_End', 'Notes'))

# LIST COL NAME = DEPLOY DETAILS COL NAME
# TYPE = always 'Raw' 
# SUB_TYPE": always 'Audio' 
# PLATFORM": always 'Drifter' 
# INSTRUMENT_TYPE = 'Type'
# INSTRUMENT_ID = 'Instrument_ID'
# DEPLOYMENT_TIME = 'Deployment_Date'
# RECOVERY_TIME = 'Recovery_Date'
# AUDIO_START = 'Date_Start' 
# AUDIO_END = 'Data_End'
# SOURCE_PATH = Path to data on DON 
# DATA_COMMENT = 'Notes'

# Copy text from database 
diText <- '{"TYPE": "Raw", 
             "SUB_TYPE": "Audio", 
             "PLATFORM": "Drifter", 
             "INSTRUMENT_TYPE": "Soundtrap 4300 HF", 
             "INSTRUMENT_ID": "1208791071", 
             "DEPLOYMENT_TIME": "2018-11-22T08:10:00", 
             "RECOVERY_TIME": "2018-12-03T00:25:00", 
             "AUDIO_START": "2018-11-22T08:28:24", 
             "AUDIO_END": "2018-12-03T00:49:11", 
             "SOURCE_PATH": "Z:/RECORDINGS/DRIFTERS/CCES_2018/RAW/CCES_023", 
             "DATA_COMMENT": "Low frequency strumming and knocking under 50 Hz"}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
diList <- fromJSON(diText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonDI <- toJSON(diList)
cat(jsonDI)  



## ANCILLARY_INFO COLUMN ----
# data from deployDetails for list
#dd_ai <- subset(deployDetails, select = c())

# BIO_PATH
# OTHER_PATH 
# TEMP_PATH

# Copy text from database 
aiText <- '{"BIO_PATH": "", 
            "OTHER_PATH": "Z:/METADATA/CCES_2018/CCES_023", 
            "TEMP_PATH": "Z:/RECORDINGS/DRIFTERS/CCES_2018/RAW/CCES_023/Temp Files"}'

# Turn that into an R list. We can look at this R list and use it as a template 
# for the list we want to create
aiList <- fromJSON(aiText)

# Next figure out how to fill in the pieces of the above list with our own data 
# from deploydetails/etc,

# And turn that list into a JSON text
jsonAI <- toJSON(aiList)
cat(jsonAI)



# ADDITIONAL DATA CLEANING ----
# Change soundtrap names
dd[dd == "ST640"] <- "SoundTrap 640"
dd[dd == "ST4300HF"] <- "SoundTrap 4300 HF"
dd[dd == "ST300"] <- "SoundTrap 300"
dd[dd == "ST4300"] <- "SoundTrap 4300"
dd[dd == "ST500HF"] <- "SoundTrap 500 HF"
dd[dd == "ST300HF"] <- "SoundTrap 300 HF"


# Append final data table ----
con <- dbConnect(SQLite(), "PassivePacker_v.4.0.3-win64/database/packageData.sqlite")
dbAppendTable(con, "DEPLOYMENT_DATA", dd)
PP_DeploymentData <- dbReadTable(con, 'DEPLOYMENT_DATA')
dbDisconnect(con)


# Additional Automation Steps ----

## Calibration automation ---- 
# For CCES: Use calibrationinfo spreadsheet

# For PASCAL: Make calibrationinfo spreadsheet

# For ADRIFT: Make calibration table from deployment details and inventory 
# (need to link array names in deployment details to array sheet in inventory, 
# then link hydrophones in array sheet to hydrophone sheet in inventory)


## Temporary paths for folders/metadata ----
# We do not want to manipulate the folder structure on the DON, however passive
# packer needs all of the paths to be unique 
# List of paths
# - package destination : name of external hard drive, doesn't change drift to drift
# - Path to documentation files : path to reports on synology, doesn't change 
#   drift to drift (Y:/1651_CCES_2018/Report)
# - Path to audio files : FOLDER WITH ONLY RAW AUDIO FILES (.wav)
# - Path to navigation files : GPS.csv in metadata folder on DON (Z:/METADATA/CCES_2018/CCES_023/CCES_023_GPS/CCES_023_GPS.csv)
# - Path to calibration documents : path from project folder, doesn't change 
#   drift to drift  (C:/Users/kourtney.burger/Documents/GitHub/ADRIFT-Deployment-PassivePacker/Calibration info)
# - Path to temperature files : ONLY TEMP FILES IN THEIR OWN FOLDER
# - Path to other fils you wish to submit (OTHER_PATH): folder with all additional
#   data including accelerometer, logs, noise logs, depth data, etc.

#OLD CODE ----
# 2/3 Set up Passive Packer data table
  # Subset deployment details fields 
dd <- subset(deployDetails, select = c('Project', 'DeploymentID', 'Cruise', 
                                       'Platform', 'Type', 'Instrument_ID', 
                                       'Deployment_Date', 'Data_Start', 
                                       'Recovery_Date', 'Data_End'))
  # add other passive packer fields
dd <- dd %>%
  add_column(ID = NA, SITE_OR_CRUISE = NA, PACKAGE_ID = NA, SOURCE_PATH = NA,
             DESTINATION_PATH = NA, METADATA_AUTHOR = 'Kourtney Burger', 
             META_AUTHOR_UUID = NA, PUBLICATION_DATE = NA, DEPLOYMENT_ALIAS = NA,
             SITE_ALIAS = NA, TITLE = "California Current Ecosystems Survey - Passive Acoustics Survey", 
             PURPOSE = "From Report", ABSTRACT = "From Report", DATA_COMMENT = NA, 
             TEMP_PATH = NA, BIO_PATH = NA, OTHER_PATH = NA,
             DOCS_PATH = NA, CALIBRATION_PATH = NA, CREATION_TIME = NA, 
             UPDATE_TIME = NA, USE = 'Y', SAMPLING_DETAILS = NA, 
             QUALITY_DETAILS = NA, SCIENTISTS = NA, SPONSERS = NA, FUNDERS = NA, 
             SENSORS = NA, DEPLOYMENT_DETAILS = NA, CALIBRATION_INFO = NA, 
             DATASET_INFO = NA, ANCILLARY_INFO = NA)

  # reorder and rename columns
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

  # Fix project and package_id fields (combine columns and remove spaces)
dd$PROJECT <- paste('SWFSC_',dd$PROJECT)
dd$PROJECT <- gsub(" ","",dd$PROJECT)

dd$PACKAGE_ID <- paste(dd$PROJECT,'_',dd$SITE_CRUISE,'_',dd$DEPLOYMENT_ID)
dd$PACKAGE_ID <- gsub(" ","",dd$PACKAGE_ID)

  # Change soundtrap names
dd[dd == "ST640"] <- "SoundTrap 640"
dd[dd == "ST4300HF"] <- "SoundTrap 4300 HF"
dd[dd == "ST300"] <- "SoundTrap 300"
dd[dd == "ST4300"] <- "SoundTrap 4300"
dd[dd == "ST500HF"] <- "SoundTrap 500 HF"
dd[dd == "ST300HF"] <- "SoundTrap 300 HF"

# 4. Write manipulated data frame to existing passive packer database
con <- dbConnect(SQLite(), "PassivePacker_v.4.0.3-win64/database/packageData.sqlite")
dbWriteTable(con, 'DEPLOYMENT_DATA', dd, overwrite = TRUE)
dbDisconnect(con)

#dbappendtable()


  # check data table for errors and correct data types
#db <- dbConnect(SQLite(), "PassivePacker_v.4.0.2-win64/database/packageData.sqlite")
#PP_DeploymentData <- dbReadTable(db, 'DEPLOYMENT_DATA')
#str(PP_DeploymentData)


#ADDITIONAL AUTOMATION STEPS
# Make calibration table from deployment details and inventory (need to link 
# array names in deployment details to array sheet in inventory, then link
# hydrophones in array sheet to hydrophone sheet in inventory)

