import pytest
import os
import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import XDC_nb

from datetime import datetime


@pytest.fixture
def supply_params():
    start_date = datetime.date(
        datetime.strptime('10-12-2018 00:00:00', "%m-%d-%Y %H:%M:%S"))
    end_date = datetime.date(
        datetime.strptime('11-10-2018 00:00:00', "%m-%d-%Y %H:%M:%S"))
    onedata_token = ("MDAyOGxvY2F00aW9uIG9uZXpvbmUuY2xvdWQuY25hZi5pbmZ"
                     "uLml00CjAwMzBpZGVudGlmaWVyIDk4OTgwNjc1MWU00NjhlZ"
                     "jA1ODZjNzMwZDNjNjVjN2IxCjAwMWFjaWQgdGltZSA8IDE2M"
                     "TcxNzY1NTkKMDAyZnNpZ25hdHVyZSChV36AW00frfBqr02Cp"
                     "D3B6SxVXnVMuP8vsHE6yEqJFsKgo")
    return [start_date, end_date, onedata_token]


def test_model_meta_discovery(supply_params):
    result = XDC_nb.find_dataset_type(
        supply_params[0], supply_params[1], '', supply_params[2])
    assert len(result) > 0
