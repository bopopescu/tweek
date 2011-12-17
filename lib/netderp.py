import csv
import boto
from boto.s3.connection import S3Connection
from boto.s3.key import Key

# Ultra-important secret keys
ACCESS_KEY = ""
SECRET_KEY = ""
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

