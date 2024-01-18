# Fix calibration file for adrift

calInfo <- read.csv("~/GitHub/ADRIFT-Deployment-PassivePacker/Calibration Files/ADRIFT_CalibrationInfo.csv")
inven <- read.csv("~/GitHub/ADRIFT-Deployment-PassivePacker/Calibration Files/Inventory - Hydrophones.csv")

for (i in 1:nrow(calInfo)) {
#  for (i in 1) {
  calInfo$HydrophoneType_1[i] <- inven$Model[inven$Serial.Number == calInfo$SerialNumber_1[i]]
}

for (i in 1:nrow(calInfo)) {
  calInfo$HydrophoneType_2[i] <- inven$Model[inven$Serial.Number == calInfo$SerialNumber_2[i]]
}

for (i in 1:nrow(calInfo)) {
  calInfo$HydrophoneType_3[i] <- inven$Model[inven$Serial.Number == calInfo$SerialNumber_3[i]]
}



for (i in 1:nrow(calInfo)) {
  calInfo$HydrophoneSensitivity_1[i] <- inven$Hydrophone.Sensitivity.dB.re..1V.uPa[inven$Serial.Number == calInfo$SerialNumber_1[i]]
}  
  
for (i in 1:nrow(calInfo)) {
  calInfo$HydrophoneSensitivity_2[i] <- inven$Hydrophone.Sensitivity.dB.re..1V.uPa[inven$Serial.Number == calInfo$SerialNumber_2[i]]
}

for (i in 1:nrow(calInfo)) {
  calInfo$HydrophoneSensitivity_3[i] <- inven$Hydrophone.Sensitivity.dB.re..1V.uPa[inven$Serial.Number == calInfo$SerialNumber_3[i]]
}



for (i in 1:nrow(calInfo)) {
  calInfo$Current_mA_1[i] <- inven$Current.mA[inven$Serial.Number == calInfo$SerialNumber_1[i]]
}

for (i in 1:nrow(calInfo)) {
  calInfo$Current_mA_2[i] <- inven$Current.mA[inven$Serial.Number == calInfo$SerialNumber_2[i]]
}

for (i in 1:nrow(calInfo)) {
  calInfo$Current_mA_3[i] <- inven$Current.mA[inven$Serial.Number == calInfo$SerialNumber_3[i]]
}

write.csv(calInfo, "~/GitHub/ADRIFT-Deployment-PassivePacker/Calibration Files/ADRIFT_CalibrationInfo.csv")
