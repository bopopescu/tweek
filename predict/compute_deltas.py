import os.path
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), "../lib"))

from netderp import *
from timederp import *

def get_stock_value(domain, ticker, time):
    try:
        item = sdb_get_item(domain, ticker, time)
        return float(item["value"])
    except Exception:
        print item

earliest_timestamp = "20111025-18"
earliest_time = timestamp2time(earliest_timestamp)

if __name__ == "__main__":
    domain = sdb_get_domain()

    for item in domain:
        (ticker, timestamp) = sdb_parse_name(item.name)
        time = timestamp2time(timestamp)

        if ticker == 'DJI' or ticker == 'INDU':
            continue

        # Current recorded value of the stock
        curr_value = get_stock_value(domain, ticker, time)

        if time > earliest_time:
            prev_time = get_prev_hour(time)
            prev_value = get_stock_value(domain, ticker, prev_time)
            print ticker, time
            delta = curr_value - prev_value
            percent = 0

            if abs(prev_value) > 0:
                percent = delta / prev_value

            print ticker, time, prev_time, delta, percent, curr_value, prev_value
            item["hourly-change"] = delta
            item["hourly-rel-change"] = percent
            item.save()
        else:
            print ticker, time, "EARLIEST", 0, 0, curr_value, "EARLIEST"
            item["hourly-change"] = 0
            item["hourly-rel-change"] = 0
            item.save()

