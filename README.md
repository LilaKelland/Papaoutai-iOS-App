# Papaoutai
Bathroom time-usage app.

*Still a work in progress*

This iOS app was developed almost entirely to bring hard data to the conversation when discussing the amount a partner spends (aka hides) in the bathroom. This repository contains the 2 iOS apps - working on threading to combine the 2 into one app. 

There are three components to this system:
1. Arduino Nano - used as a BLE peripheral to track proximity of an iPhone when in the bathroom. 
2. iOS app (iOS Proximity App) - used as the BLE central device, to transmit time and proximity to the database, and recieve weekly alerts on usage stats (like screen-time app) ((iOS Usage Charts App)
3. Python REST API 
