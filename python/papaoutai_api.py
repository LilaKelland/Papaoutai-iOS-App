# Papaoutai_API.py
# Feb 2021


from bottle import Bottle, response, request
import json
from datetime import datetime
from bson.json_util import loads
from bson.json_util import dumps
from pymongo import MongoClient
import config

# import papaoutai_main
from pprint import pprint
import time

client = MongoClient(config.mongoClient)
db = client.pymongo_test
sessions = db.sessions
app = Bottle()


@app.route("/addSession", method="POST")
def addSession():
    """Adds time spent in bathroom entry when arduino disconnects from iPhone"""
    try:
        user_id = request.POST.get("user_id")
        start_time = request.POST.get("startTime")
        duration = request.POST.get("duration")

        session_data = {
            "user_id": user_id,
            "start_time": start_time,
            "duration": duration,
            "start_datetime": datetime.fromtimestamp(start_time),
        }
        print(session_data)

        sessions.insert_one(session_data)

        # db.papaoutaiSession.insert_one({"$set":session_data}, upsert=True)
        # with open("papaoutai_session.json", "w") as outfile:
        #     json.dump(session_data, outfile)
        print("yay I think db entry worked! ")
        return "success"

    except:
        print("didnt work")


@app.route("/launchStatsPage")
def launchStatsPage():
    """launches webpage after ios button pressed"""
    try:
        user_id = request.GET.get("user_id")
        print("yay", user_id)
        return "success"
    # TODO retrieve data for user_id from db - and run webpage

    except:
        print("didnt work")


if __name__ == "__main__":
    # app.run(host='0.0.0.0', port=8080, debug=True, reloader=True) # run on pi server
    app.run(
        host="192.168.4.29", port=8080, debug=True, reloader=True
    )  # run on computer
