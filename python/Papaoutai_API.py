# Papaoutai_API.py
# Feb 2021


from bottle import Bottle, response, request
import json
#from bson.json_util import loads
#from bson.json_util import dumpsp
from pymongo import MongoClient
from pprint import pprint
import time

client = MongoClient("mongodb://127.0.0.1:27017/pymongo_test")
db = client.pymongo_test
app = Bottle()

@app.route('/addSession')
def addSession():
    """Adds time spent in bathroom entry when arduino disconnects from iPhone"""
    try:
        session_data = {
            "start_time":"startTime",
            "elaspsed_time": "elapsedTime"
        } 
        #TODO add in id
   # db.papaoutai_sessions.insert_one(session_data) 
    #print(session_data)
    except: 
        print ("didnt work")


# @app.route('/setToken')
# def getToken():
#     """Get token for APNS"""

#     token = request.GET.get("tokenString")
#     setToken(token)

# def setToken(token):
#     tokenData = {
#           "token": token,
#     }
#     db.papaoutai_token.insert_one(tokenData)


# @app.route('/fakeXcode')
# #simulated sensors - in times when sensors not available
# def GetSimulatedValues():
#     return({"startTime":1564646464434.5664,"elaspsedTime":3.0})

#         with open("isBurning.json", "w") as outfile: 
#             json.dump(actuallyBurning, outfile) 
        
#         db.unBurntIsBurning.insert_one({actuallyBurning})
#             #TODO add grab /link other required info for supervised learning 
#         return("success")
        
#     except:
#         return("didn't work")
    


if __name__ == '__main__':
    #app.run(host='0.0.0.0', port=8080, debug=True, reloader=True) # run on pi server
    app.run(host='192.168.4.29', port=8080, debug=True, reloader=True) # run on computer


