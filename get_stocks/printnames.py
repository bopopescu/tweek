#!/usr/local/bin/python2.7

# Sanity check. This will cat all items in our SimpleDB setup. We can use this to verify that
# we actually inserted something.

import boto
import csv
import datetime
import subprocess

if __name__ == "__main__":
    sdb = boto.connect_sdb("access-key", "secret-key")
    domain = sdb.get_domain("stock-data")

    for item in domain:
        print item.name
        # print item
