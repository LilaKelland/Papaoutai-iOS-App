import pytest
from papaoutai_main import split_session_entry_into_min_per_hours, upload_hour_segment_to_db #, find_exisiting_record, calc_total_bathrooming_for_day, calc_avg_bathrooming_for_week, format_for_charting_day

# #TODO monkey patch api calls in cofftest.py
# @pytest.fixture
# def example_new_session():
#     return (
#         new_session = {
#             "user_id": 123,
#             "start_time": ,
#             "duration": 5234,
#             "start_datetime": datetime.datetime.fromtimestamp()
#         }
#     )

start_time = (323737 + 36000)
start_datetime = datetime.datetime.fromtimestamp(start_time)
duration = 4567
end_datetime = start_datetime + datetime.timedelta(seconds=duration)
session_day = start_datetime.day
user_id = 123
_id = 12345

def test_format_for_charting_day():
    format_for_charting_day(day: date)
# test_split_session_entry_into_min_per_hours():

# test rollover year, roll over month, leap year, rollover day then redactor
# time zone
# normalassert
# None

# average
# test empty days in middle of week,
# test empyy at end
# empty at beginning
# None

def test_always_passes():
    assert True

def test_always_fails()
    assert False


def test_with_input():
    result = with_input("blue")
    assert result["old"] == "blue"

def split_session_entry_into_min_per_hours_test_case():
    pass


def test_rollover_day(self):
        pass

def test_single_day(self):
        pass

    # def tearDown(self):
    #     self.entry.dispose() or delete db entry

