import os.path
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), "../lib"))

from netderp import *
from timederp import *

def get_stock_value(domain, ticker, time):
    item = sdb_get_item(domain, ticker, time)

    a = [u"JNJ", u"AAPL", u"SNE", u"MSFT"]

    if not item:
        return 0
    elif ticker in a:
        return (float(item[u'Ask (Real-time)']) + float(item[u'Bid (Real-time)'])) / 2
    elif u'Last Trade (Real-time) With Time' in item:
        x = item[u'Last Trade (Real-time) With Time']
        return float(x.split('<')[1][2:])
    else:
        return 0

def has_entry(domain, ticker, time):
    item = sdb_get_item(domain, ticker, time) 
    print item
    # return item != None
    return item and u"Ask (Real-time)" in item and abs(get_stock_value(domain, ticker, time)) > 10**-5

earliest_timestamp = "20111025-18"    
earliest_time = timestamp2time(earliest_timestamp)
latest_timestamp = "20111209-20"
latest_time = timestamp2time(latest_timestamp)

#tickers = ['INDU', 'SNE', '^NQUSA', 'AAPL', '^NDX', '^IXIC', 'JNJ', '^DJI', 'MSFT']
tickers = ['DJI']
domain = sdb_get_domain()

for ticker in tickers:
    current_time = earliest_time
    num_elapsed_hours = 0
    last_valid_time = earliest_time
    last_valid_value = get_stock_value(domain, ticker, current_time)
    current_time = get_next_hour(current_time)    
    seeking_next_valid = False

    while current_time < latest_time:
        entry = has_entry(domain, ticker, current_time)
        print current_time
        if entry:
            if seeking_next_valid:
                # Exiting invalid zone
                print "Padding from " + time2timestamp(last_valid_time) + " to " + time2timestamp(current_time)
                
                end_value = get_stock_value(domain, ticker, current_time)
                delta = (end_value - last_valid_value) / num_elapsed_hours
                now = get_next_hour(last_valid_time) 

                for i in range(1, num_elapsed_hours + 1):
                    item = sdb_ensure_item(domain, ticker, now)
                    value = last_valid_value + delta * i
                    print ticker, now, value
                    item["value"] = value  
                    item.save()

                    now = get_next_hour(now)

                print "Done!"

                seeking_next_valid = False
            else:
                last_valid_time = current_time
                last_valid_value = get_stock_value(domain, ticker, current_time)
                
                item = sdb_get_item(domain, ticker, current_time)
                print ticker, current_time, last_valid_value
                item["value"] = last_valid_value
                item.save()
        else:
            if seeking_next_valid:
                num_elapsed_hours += 1
            else:
                # Entering invalid zone
                num_elapsed_hours = 2
                seeking_next_valid = True

        current_time = get_next_hour(current_time)
            
