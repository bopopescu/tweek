#!/usr/local/bin/python2.7

# Sanity check. This will cat all items in our SimpleDB setup. We can use this to verify that
# we actually inserted something.

import boto
import csv
import datetime
import subprocess

ACCESS_KEY = ""
SECRET_KEY = ""

if __name__ == "__main__":
    sdb = boto.connect_sdb(ACCESS_KEY, SECRET_KEY)
    domain = sdb.get_domain("stock-data")

    for item in domain:
        print item.name
        item["value"] = 0;
        item.save();

#    i = domain.get_item("INDU-20111027-01")
#    for x in i:
#        print x + ": " + i[x]
