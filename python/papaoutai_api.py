# Papaoutai_API.py
# Feb 2021


from bottle import Bottle, response, request
import json
from datetime import datetime
from bson.json_util import loads
from bson.json_util import dumps
from pymongo import MongoClient
import config
import papaoutai
from pprint import pprint
import time
import logging

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
        start_datetime = datetime.fromtimestamp(start_time)

        session_data = {
            "user_id": user_id,
            "start_time": start_time,
            "duration": duration,
            "start_datetime": start_datetime,
        }
        print(session_data)

        session_id = sessions.insert_one(session_data)
        print("yay I think db entry worked! ")

        papaoutai.parse_session_data(session_id, user_id, start_datetime)

        return "success"

    except:
        print("didnt work")
        logging.error("addSession db entry didn't work")


@app.route("/launchStatsPage")
def launchStatsPage():
    """launches webpage after ios button pressed"""
    try:
        # user_id = request.POST.get("user_id")
        day = request.GET.get("day")
        (
            week_daily_totals,
            avg_bathrooming_min_per_day,
            weekday_abrvs,
            days_of_month,
        ) = calc_bathrooming_for_week(day)
        chart_data = {
            week_daily_totals: "week_daily_totals",
            avg_bathrooming_min_per_day: "avg_bathrooming_min_per_day",
            weekday_abrvs: "weekday_abrvs",
            days_of_month: "days_of_month",
        }
        print("yay")
        return json.loads(dumps(chart_data))

    except:
        print("didnt work")
        logging.error("launchStatsPage db entry didn't work")


if __name__ == "__main__":
    # app.run(host='0.0.0.0', port=8080, debug=True, reloader=True) # run on pi server
    app.run(
        host="192.168.4.29", port=8080, debug=True, reloader=True
    )  # run on computer
