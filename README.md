# Papaoutai
Bathroom time-usage app.

*Still a work in progress*

This iOS app was developed almost entirely to bring hard data to the conversation when discussing the amount a partner spends (aka hids) in the bathroom. I also thought Angular looked pretty cool and wanted learn that as well.  

There are four components to this system:
1. Arduino Nano - used as a BLE peripheral to track proximity of an iPhone when in the bathroom. 
2. iOS app - used as the BLE central device, to transmit time and proximity to the database, and recieve weekly alerts on usage stats (like screen-time app).  
3. Python -  used as an interface between iOS and MongoDB and to process the descrete sessions. 
4. Angular SPA (probably more elegant to have it directly on the app, but, new skills.) *Still working on this*






