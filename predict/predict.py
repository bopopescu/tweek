import os.path
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), "../lib"))

import os
from netderp import *
from timederp import *

tickers = ["^IXIC", "^NQUSA", "^NDX", "INDU"]
#top_n = [5, 10, 15, 20, 25, 50]
top_n = [15]
output_dir = "output/"

def ensure_dir(f):
    d = os.path.dirname(f)
    if not os.path.exists(d):
        os.makedirs(d)

def sanitize_similarity_entries(entries):
    sanitized_entries = [ e.split("\t") for e in entries ]

    total_similarity = 0
    for entry in sanitized_entries:
        entry[0] = timestamp2time(entry[0])
        entry[1] = float(entry[1])
        entry[2] = float(entry[2])

        total_similarity += entry[1]

    for entry in sanitized_entries:
        entry[1] /= total_similarity

    return sanitized_entries

def get_all_ticker_deltas(time):
    timestamp = time2timestamp(time)
    deltas = []

    entry_names = [ "%s-%s" % (t, timestamp) for t in tickers ]
    entries = [ domain.get_item(en) for en in entry_names ]
    deltas = [ float(e["hourly-rel-change"]) for e in entries if e ]

    if len(deltas) == 0:
        # Argh, sanitization
        return [0]
    else:
        return deltas

def get_estimated_change(valid_similar_entries, n):
    estimated_change = 0
    total_similarity = 0
    num_added = 0

    for similar_time, similarity, size in valid_similar_entries:
        comparison_time = get_next_hour(similar_time)
        
        # Get average change across all of our tickers
        deltas = get_all_ticker_deltas(comparison_time)
        average_delta = sum(deltas) / len(deltas)        

        # Mark estimate
        if abs(average_delta) > 10**-5:
            estimated_change += average_delta * similarity
            total_similarity += similarity
            num_added += 1

        if num_added >= n:
            break        

    if total_similarity == 0:
        return 0
    else:
        return estimated_change / total_similarity

# SDB domain for stock data
domain = sdb_get_domain()

# S3 connection for comparison results
bucket = s3_get_bucket()
good_keys = s3_get_similar_keys(bucket)

# Create output files
ensure_dir(output_dir)
files = dict([(n, open("%stop_%d.csv" % (output_dir, n), "w")) for n in top_n])
writers = dict([(key, csv.writer(value)) for key, value in files.items()])

for writer in writers.values():
    writer.writerow(["Time", "Accurate", "Estimate Change", "Actual Change", "Difference"])

# Grab a key
for good_key in good_keys:
    good_key_name = good_key.name
    [curr_timestamp, garbage] = good_key_name.split("/")
    curr_time = timestamp2time(curr_timestamp)

    # Actual change
    one_hour_later = get_next_hour(curr_time)
    real_deltas = get_all_ticker_deltas(one_hour_later)
    real_change = sum(real_deltas) / len(real_deltas)

    # Find prediction
    all_similar = s3_fetch_key(bucket, good_key).strip().split("\n")
    all_similar_entries = sanitize_similarity_entries(all_similar)
    valid_similar_entries = filter(lambda e: e[0] < curr_time, all_similar_entries)
    
    for num in top_n:
        print "Processing top %d for %s..." % (num, time2str(curr_time))
  
        estimated_change = get_estimated_change(valid_similar_entries, num)    
        change_delta = abs(estimated_change - real_change)
    
        is_accurate = estimated_change * real_change >= 0

        print time2str(curr_time), is_accurate, estimated_change, real_change, change_delta
        output_file = writers[num]
        output_file.writerow([time2str(curr_time), is_accurate, estimated_change, real_change, change_delta])

    print "Done with %s!" % (time2str(curr_time))

for file in files.values():
    file.close()

