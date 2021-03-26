"""papaoutai_pymongdb_setup.py.py
run this before running Papaoutai_API/ Papaoutai_Main"""

import pymongo
from pymongo import MongoClient

# TODO - Change this out
client = MongoClient("mongodb://127.0.0.1:27017/pymongo_test")
db = client.pymongo_test

# set up collections and model
papaoutaiSession = db.papaoutaiSession

session_data_setup = {
    # "_id": "",
    "start_time": "",
    "elaspsed_time": "",
}
papaoutaiSession.insert_one(session_data_setup)
