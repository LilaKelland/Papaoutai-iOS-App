from pymongo import MongoClient
from datetime import date
import datetime
import time
import config
import math
import logging

# TODO exceptions
cluster = MongoClient(config.mongoURI)
db = cluster.get_database("papaoutai")  # or db = cluster["papaoutai"]

sessions = db.sessions
# chart_data = db.chart_data
now = time.time()


def parse_session_data(session_id, user_id, start_datetime):
    (
        user_id,
        session_id,
        session_minutes,
        datetime_start_of_the_hour,
    ) = split_session_entry_into_min_per_hours(session_id)
    upload_hour_segment_to_db(
        user_id, session_id, session_minutes, datetime_start_of_the_hour
    )
    calc_total_bathrooming_for_day(start_datetime)
    return "success"


def split_session_entry_into_min_per_hours(session_id):
    (start_datetime, user_id, duration) = sessions.find_one({"_id": "session_id"})

    end_datetime = start_datetime + datetime.timedelta(seconds=duration)

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

        return (user_id, session_id, session_minutes, datetime_start_of_the_hour)


def upload_hour_segment_to_db(
    user_id, session_id, session_minutes, datetime_start_of_the_hour
):
    # try:
    #     exisiting_session_mintues = find_exisiting_record(datetime_start_of_the_hour, user_id)

    # if exisiting_session_mintues != nil:
    #         session_minutes = exisiting_session_mintues['session_minutes'] + session_minutes
    #         if session_minutes > 60:
    #             logging.exception("too many minutes")
    #             session_minutes = 60
    # else:
    try:
        new_entry = {
            "user_id": user_id,
            "session_id": _id,
            "session_minutes": session_minutes,
            "datetime_start_of_the_hour": datetime_start_of_the_hour,
        }
        chart_data.insert_one(new_entry)

        print(new_entry)
        print("yay new entry sucess! \n")

    except:
        print("ACK didnt get in db! \n")
        logging.exception("Exception logged - didnt insert chart data record in db")


# except:
#     logging.exception(f'Exception logged - couldn''t find existing minutes')


def find_exisiting_record(datetime_start_of_the_hour, user_id):
    pass
    # session_minutes = sessions.find_one({}, {user_id: user_id, datetime_start_of_the_hour}) and session minutes
    # if value
    # return( session_minutes)
    # else return none


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

    print(total_bathrooming_minutes)
    return total_bathrooming_minutes


def calc_bathrooming_for_week(day: date):
    """note that using this means the day starts on monday - can change to shift this by one later
    formats for charting"""
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
    weekday_abrvs = []
    days_of_month = []

    for i in range(num_of_days_in_week):
        total_bathrooming_minutes = calc_total_bathrooming_for_day(day_to_add)
        week_daily_totals.append(total_bathrooming_minutes)

        weekday_abrvs.append(day_to_add.strftime("%a"))
        days_of_month.append(day_to_add.day)

        week_daily_totals.append(total_bathrooming_minutes)
        day_to_add = monday + datetime.timedelta(days=i + 1)

        print(f"total_bathrooming_minutes {total_bathrooming_minutes}")
        print(f"day {day_to_add}\n")

    avg_bathrooming_min_per_day = math.floor(
        sum(week_daily_totals) / num_of_days_in_week
    )
    print(f"week_daily_totals {week_daily_totals}")
    print(f"avg_bathrooming_min_per_day {avg_bathrooming_min_per_day}")
    print(f"weekday_abrevs {weekday_abrvs}")
    print(f"days of month {days_of_month}")
    return (
        week_daily_totals,
        avg_bathrooming_min_per_day,
        weekday_abrvs,
        days_of_month,
    )
