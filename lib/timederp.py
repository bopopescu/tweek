import datetime
import pytz

input_format = "%Y%m%d-%H"
eastern = pytz.timezone("US/Eastern")
output_format = "%m/%d/%y @ %I:%M%p"

def get_next_hour(time):
    return time + datetime.timedelta(hours=1)

def get_prev_hour(time):
    return time - datetime.timedelta(hours=1)

def timestamp2time(timestamp):
    temp = datetime.datetime.strptime(timestamp, input_format)
    return pytz.utc.localize(temp)

def time2timestamp(time):
    return time.strftime(input_format)

def time2str(time):
    return time.astimezone(eastern).strftime(output_format)


