from pymongo import MongoClient
from datetime import date
import datetime
import time
import config
from pprint import pprint
import math

cluster = MongoClient(config.mongoURI)
db = cluster.get_database("papaoutai")  # or db = cluster["papaoutai"]

#db collections
sessions = db.sessions
chart_data = db.chart_data


print(f" session document count {sessions.count_documents({})}")

now = time.time()


new_session = {
    "user_id": 123,
    "start_time": now,
    "duration": 5234,
    "start_datetime": datetime.datetime.fromtimestamp(now)
}


start = datetime.datetime(2021, 3, 23)
end = datetime.datetime.fromtimestamp(now)

def get_sessions(start: date, end: date):
    return( sessions.find(
        {"start_datetime": {"$gte": start, "$lt": end}}, {"start_datetime"}
    ))
get_sessions(start, end)

def split_session_entry_into_min_per_hours():
    # called when new entry * OR do at same time?? - pass in values??
    # TODO grab start_datetime, duration, from db or from API
    # TODO if existing session! (add to it )

    start_time = 323737 + 36000
    start_datetime = datetime.datetime.fromtimestamp(start_time)
    duration = 4567
    end_datetime = start_datetime + datetime.timedelta(seconds=duration)
    session_day = start_datetime.day
    user_id = 123
    _id = 12345

    if end_datetime.hour < start_datetime.hour:
        end_hour = end_datetime.hour + 24
    else:
        end_hour = end_datetime.hour

    count = 0
    for session_hour in range(start_datetime.hour, (end_hour + 1)):

        if count == 0:
            session_minutes = (
                60 - start_datetime.minute
            )  # TODO - this may result in over 60 min/ hour - floor this
            seconds_left = duration - session_minutes * 60

        else:
            if seconds_left >= 3600:
                session_minutes = 60
                seconds_left = seconds_left - 3600

            else:
                session_minutes = math.floor(seconds_left / 60)

        if session_hour >= 24:
            session_hour -= 24
            session_day = (start_datetime + datetime.timedelta(days=1)).day

        count += 1
        print(f"session_min = {session_minutes}")
        datetime_start_of_the_hour = datetime.datetime(
            start_datetime.year, start_datetime.month, session_day, session_hour
        )
        print(f"datetime_start_of_the_hour = {datetime_start_of_the_hour} ")

        # upload_hour_segment_to_db(user_id, session_id, session_minutes, datetime_start_of_the_hour)

        # ---------------------------remove below
        # try:
        #     new_entry = {
        #         'user_id': user_id,
        #         'session_id': _id,
        #         'session_minutes': session_minutes,
        #         'datetime_start_of_the_hour': datetime_start_of_the_hour
        #         }
        #     print(new_entry)
        #     chart_data.insert_one(new_entry)
        #     print("yay new entry sucess! \n")
        # except:
        #     print("ACK didnt get in db! \n")
        # ----------------------------remove above


split_session_entry_into_min_per_hours()

# TODO use strftime() to fomrat chart array, times ()
# TODO exceptions


def upload_hour_segment_to_db(
    user_id, session_id, session_minutes, datetime_start_of_the_hour
):
    pass


# TODO need an is exisiting recode
# TODO what to do in case of more than 2 records
# sessions.count_documents({}) - start from scratch and add together
# -----------------------------------------------below good
# exisiting_session_mintues = find_exisiting_record(datetime_start_of_the_hour, user_id)
# if exisiting_session_mintues != nil:

#     if (session_minutes + existing_session_minutes) <= 60
#         session minutes = (session_minutes + existing_session_minutes)
#         try:
#             print(session_minutes)
#             chart_data.update_one(where _id update sessionminutes)
#             print("yay update entry sucess! \n")
#         except:
#             print("ACK didnt get in db! \n")

#     else:
#         raise exception #too_many_minutes - return

# else:
#     try:
#         new_entry = {
#             'user_id': user_id,
#             'session_id': _id,
#             'session_minutes': session_minutes,
#             'datetime_start_of_the_hour': datetime_start_of_the_hour
#             }

#         print(new_entry)
#         chart_data.insert_one(new_entry)
#         print("yay new entry sucess! \n")
#     except:
#         print("ACK didnt get in db! \n")
# ----------------------------------------above good


def find_exisiting_record(datetime_start_of_the_hour, user_id):
    pass


# results = sessions.find({
#     'start_datetime': {
#         $and [
#             {
#               $gte: ['$st_date', new Date(st_date)],
#             },
#              {
#                 $lte: ['$end_date', new Date(end_date)],
#             }
#         ]
#     }
# })

# pprint(list(results))


def check_no_lost_entries():
    pass


"""# check and compare sessions.(id ) to hour_data for today and yesterday,
    if not in if over 60 min - log error! """


def calc_total_bathrooming_for_day(day: date):
    """adds up time per hour for a 24 hour period"""
    end = day + datetime.timedelta(days=1)
    session_hourly_times = chart_data.find(
        {"datetime_start_of_the_hour": {"$gte": day, "$lt": end}},
        {"session_minutes", "datetime_start_of_the_hour"},
    )

    bathroom_minutes_per_hour = []
    for i in session_hourly_times:
        if "session_minutes" in i:
            session_minutes = i["session_minutes"]
            bathroom_minutes_per_hour.append(session_minutes)

    total_bathrooming_minutes = sum(bathroom_minutes_per_hour)
    weekday_abrv = day.strftime("%a")
    print(weekday_abrv)
    return total_bathrooming_minutes  # , weekday_abrv)


calc_total_bathrooming_for_day(datetime.datetime(1970, 1, 5))


def calc_avg_bathrooming_for_week(day: date):
    """note that using this means the day starts on monday - can change to shift this by one later"""
    numeric_day_of_week = datetime.datetime.weekday(day)
    today_numeric_day_of_week = datetime.datetime.now().weekday()

    days_since_today = (datetime.datetime.today() - day).days

    if days_since_today > today_numeric_day_of_week:
        num_of_days_in_week = 7
    else:
        num_of_days_in_week = today_numeric_day_of_week + 1

    monday = day - datetime.timedelta(days=numeric_day_of_week)
    day_to_add = monday
    week_daily_totals = []
    for i in range(num_of_days_in_week):
        total_bathrooming_minutes = calc_total_bathrooming_for_day(day_to_add)
        week_daily_totals.append(total_bathrooming_minutes)
        day_to_add = monday + datetime.timedelta(days=i + 1)

        print(f"total_bathrooming_minutes {total_bathrooming_minutes}")
        print(f"day {day_to_add}\n")

    avg_bathrooming_min_per_day = math.floor(
        sum(week_daily_totals) / num_of_days_in_week
    )
    return avg_bathrooming_min_per_day

    print(f"week_daily_totals {week_daily_totals}")
    print(f"avg_bathrooming_min_per_day {avg_bathrooming_min_per_day}")


calc_avg_bathrooming_for_week(datetime.datetime(1970, 1, 5))


def format_for_charting_day(day: date):
    print(
        "Yesterday Date format change:",
        (datetime.datetime.now() - datetime.timedelta(days=1)).strftime("%Y/%m/%d"),
    )
    # print(calendar.day_name[datetime.datetime.strptime[day].weekday()])
    print("The Weekday for a Given date({0}) is {1}".format(day, day.strftime("%a")))
    print(
        "The Weekday for a Given date({0}) is {1}".format(
            datetime.datetime.now(), datetime.datetime.now().strftime("%a")
        )
    )


day = datetime.datetime.today()
print("The Weekday for a Given date({0}) is {1}".format(day, day.strftime("%a")))
