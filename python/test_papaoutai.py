import pytest
import papaoutai_main

@pytest.fixture
def example_new_session():
    return (
        new_session = {
            "user_id": 123,
            "start_time": now,
            "duration": 5234,
            "start_datetime": datetime.datetime.fromtimestamp(now)
        }
    )

# import test
# testsplit_session_entry_into_min_per_hours()
# test rollover year, roll over month, leap year, rollover day then redactor
# time zone
# normalassert
# None

# average
# test empty days in middle of week,
# test empyy at end
# empty at beginning
# None


class TestAbilityToTest(unittest.TestCase):
    def test_ability_to_test(self):
        self.assertEqual(1, 1)


def test_with_input():
    result = with_input("blue")
    assert result["old"] == "blue"

class split_session_entry_into_min_per_hours_test_case(unittest.TestCase):

    # def setUp(self):
    #     self.new_session = {
    #         'user_id': 123,
    #         'start_time': 1 #replace with datetime.datetime,
    #         'duration': 5234,
    #         'start_datetime': datetime.datetime.fromtimestamp(15678744)
    #         }

    def test_rollover_day(self):
        pass

    def test_single_day(self):
        pass

    # def tearDown(self):
    #     self.entry.dispose() or delete db entry


class upload_hour_segment_to_db_test_case(unittest.TestCase):
    def setUp(self):
        pass


if __name__ == "__main__":
    unittest.main()
