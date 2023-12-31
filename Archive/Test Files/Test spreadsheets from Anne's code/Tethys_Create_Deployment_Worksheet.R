#Prepare deployment details for Tethys
#Anne Simonis

#Create worksheet with 3 searate tabs: GPS, deployDetails, SensorDetails

#Must have GPS data saved in separate 'GPS' folder within the same folder
#where all deployment info is saved 

##Example
#ProjectID = rep('CCES',15)
#DepID=c('004','007','008','010','012','013','014','016','017',
# '018','019','020','021','022','023')
#mapply(makeTethysDep,ProjectID,DepID)

#required packages
library(dplyr)
library(xlsx)
library(openxlsx)
library(stringr)
library(here)
library(lubridate)

makeTethysDep<-function(ProjectID = 'CCES',DepID = '004'){
  
DepDir<-here('Deployment Worksheets')

#load deployment info
setwd(DepDir)
AllDeployments<-xlsx::read.xlsx('Deployment Details.xlsx',sheetName='deployDetails')

#Correct Date/Time formats
#Dates and times may be read in as characters if NAs are present
if(is.character(AllDeployments$Deployment_Date)){
  AllDeployments$Recovery_Date<-openxlsx::convertToDateTime(AllDeployments$Deployment_Date)}
if(is.character(AllDeployments$Recovery_Date)){
  AllDeployments$Recovery_Date<-openxlsx::convertToDateTime(AllDeployments$Recovery_Date)}
if(is.character(AllDeployments$Data_Start)){
  AllDeployments$Data_Start<-openxlsx::convertToDateTime(AllDeployments$Data_Start)}
if(is.character(AllDeployments$Data_End)){
  AllDeployments$Data_End<-openxlsx::convertToDateTime(AllDeployments$Data_End)}
#All dates and datetimes must be saved as POSIXct for Tethys to understand them
AllDeployments$Deployment_Date<-as.POSIXct(AllDeployments$Deployment_Date,'%m/%d/%Y',tz='UTC')
AllDeployments$Recovery_Date<-as.POSIXct(AllDeployments$Recovery_Date,'%m/%d/%Y',tz='UTC')
AllDeployments$Data_Start<-as.POSIXct(AllDeployments$Data_Start,"%m/%d/%Y %H:%M",tz='UTC')
AllDeployments$Data_End<-as.POSIXct(AllDeployments$Data_End,"%m/%d/%Y %H:%M",tz='UTC')

AllDeployments<-AllDeployments %>%
  mutate(Depth_Sensor=as.numeric(Depth_Sensor),
         Recovery_Latitude=as.numeric(Recovery_Latitude),
         Recovery_Longitude=as.numeric(Recovery_Longitude),
         SensorNumber_1=as.numeric(SensorNumber_1),
         SensorNumber_2=as.numeric(SensorNumber_2),
         SensorNumber_3=as.numeric(SensorNumber_3))

#create dataframe for individual deployment 
Deployment<-AllDeployments %>% 
  filter(Project==ProjectID,DeploymentID==as.numeric(DepID)) 

#create separate dataframe for sensors
Sensors<-Deployment %>%
  summarize(Data_ID=Data_ID,
            ChannelNumber=c(ChannelNumber_1,ChannelNumber_2,ChannelNumber_3),
            SensorNumber=c(SensorNumber_1,SensorNumber_2,SensorNumber_3)) %>%
  mutate(ChannelNumber=as.numeric(ChannelNumber)) %>%
  na.omit()

#remove sensor info from deployment dataframe
Deployment<-Deployment %>%
  select(-c(ChannelNumber_1,ChannelNumber_2,ChannelNumber_3,
            SensorNumber_1,SensorNumber_2,SensorNumber_3))

#load GPS data
GPSDir<-here('Deployment Worksheets','GPS')
GPSfiles<-dir(path=GPSDir,pattern='GPS')
GPSInd<-which(str_match(GPSfiles,paste0(ProjectID,'_',DepID))>0)
GPSdata<-read.csv(file.path(GPSDir,GPSfiles[GPSInd]))
GPSdata$UTC<-as.POSIXct(GPSdata$UTC,format='%Y-%m-%d %H:%M:%S',tz='UTC')

#Create worksheet
DepFile<-paste0(ProjectID,'_',DepID,'_DeployDetails.xlsx')
DepFilePath = file.path(DepDir,DepFile)

wb = createWorkbook()
shtDeployDetails = addWorksheet(wb, "deployDetails")
shtGPS = addWorksheet(wb, "GPS")
shtSensor = addWorksheet(wb, "Sensor")
writeData(wb,shtDeployDetails,Deployment)
writeData(wb,shtGPS,GPSdata) 
writeData(wb,shtSensor,Sensors) 
saveWorkbook(wb,DepFilePath,overwrite=TRUE)
}
