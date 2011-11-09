#!/usr/local/bin/python2.7

import boto
import csv
import datetime
import subprocess

ACCESS_KEY = ""
SECRET_KEY = ""

if __name__ == "__main__":
    f = open('data')
    days = [x.strip().split(" ") for x in f.readlines()]
    print days


    sdb = boto.connect_sdb(ACCESS_KEY, SECRET_KEY)
    domain = sdb.get_domain("stock-data")

    data = {} 
    dates = set()
    
    for item in domain:
        [ticker, date, hour] = item.name.split("-")
        key = "%s-%s" % (date, hour)
        
        if key not in dates:
            dates.add(key)
            data[key] = {}

        b = [u"JNJ"]
        a = [u"AAPL", u"SNE", u"MSFT"]

        if ticker in b:
            data[key][ticker] = item[u'Price/Sales']
        elif ticker in a:
            data[key][ticker] = item[u'Ask (Real-time)']
        else:
            x = item[u'Last Trade (Real-time) With Time']
            data[key][ticker] = x.split('<')[1][2:]

    f = open('data')
    days = [x.split(" ") for x in f.readlines()]

    for pair in days:
        print sorted(data.keys())

        curr_date = pair[0]
        next_date = ""
        [date, hour] = [int(x) for x in curr_date.split("-")]
        if hour == 23:
            next_date = "%d-00" % (date + 1)
        else:
            next_date = "%d-%d" % (date, hour + 1)

        # compute diffs, somehow?
        # print data[unicode(curr_date, 'utf-8')] 
        # print data[unicode(next_date, 'utf-8')]
   
