import csv
import boto
from boto.s3.connection import S3Connection
from boto.s3.key import Key

from derpkeys import *
from timederp import *

s3_comparison_bucket = "twtr-compare"
sdb_stock_domain = "stock-data"

# The S3 stuff (where comparisons are stored)
def s3_get_bucket():
    conn = S3Connection(ACCESS_KEY, SECRET_KEY)
    return conn.get_bucket(s3_comparison_bucket)

def s3_get_similar_keys(bucket):
    keys = bucket.get_all_keys()
    good_keys = filter(lambda k: k.name.find("part-00000") != -1, keys)
    return good_keys

def s3_fetch_key(bucket, target_key):
    key = Key(bucket)
    key.key = target_key
    return key.get_contents_as_string()

# The SDB stuff (where stock data is stored)
def sdb_get_domain():
    sdb = boto.connect_sdb(ACCESS_KEY, SECRET_KEY)
    domain = sdb.get_domain(sdb_stock_domain)
    return domain

def sdb_parse_name(item_name):
    index = item_name.find("-")
    return (item_name[:index], item_name[index+1:])

def sdb_make_name(ticker, time):
    return "%s-%s" % (ticker, time2timestamp(time))

def sdb_get_item(domain, ticker, time):
    name = sdb_make_name(ticker, time)
    return domain.get_item(name)

def sdb_ensure_item(domain, ticker, time):
    trial = sdb_get_item(domain, ticker, time)
    if trial:
        return trial
    else:
        return domain.new_item(sdb_make_name(ticker, time))



