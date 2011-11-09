#!/usr/local/bin/python2.7

# Sanity check. This will cat all items in our SimpleDB setup. We can use this to verify that
# we actually inserted something.

import boto
import csv
import datetime
import subprocess
import CairoPlot

ACCESS_KEY = ""
SECRET_KEY = ""

if __name__ == "__main__":
    sdb = boto.connect_sdb(ACCESS_KEY, SECRET_KEY)
    domain = sdb.get_domain("stock-data")

    data = {}
    tickers = set()
    
    for item in domain:
        [ticker, date, hour] = item.name.split("-")
        
        if ticker not in tickers:
            tickers.add(ticker)
            data[ticker] = {}

        b = [u"JNJ"]
        a = [u"AAPL", u"SNE", u"MSFT"]

        if ticker in b:
            data[ticker]["%s-%s" % (date, hour)] = item[u'Price/Sales']
        elif ticker in a:
            data[ticker]["%s-%s" % (date, hour)] = item[u'Ask (Real-time)']
        else:
            x = item[u'Last Trade (Real-time) With Time']
            data[ticker]["%s-%s" % (date, hour)] = x.split('<')[1][2:]

    
    plottable = {}
    for ticker in data:
        dates = sorted(data[ticker])
        plottable[ticker] = []

        for date in dates:
            plottable[ticker].append(float(data[ticker][date]))

    for x in plottable:
        print x
        print plottable[x]
        print '-'*80
    
    CairoPlot.dot_line_plot("stocks.png",
                            plottable,
                            800,
                            600,
                            axis = True,
                            grid = True)
