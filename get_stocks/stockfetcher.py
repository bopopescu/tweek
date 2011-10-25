#!/contrib/bin/python2.7

# Grabs stock data from Yahoo! Finance API and adds it into our SimpleDB configuration.

import boto
import csv
import datetime
import subprocess

options = {
    "s": "Symbol",
    "n": "Name",
    "a": "Ask",
    "a2": "Average Daily Volume",
    "a5": "Ask Size",
    "b": "Bid",
    "b2": "Ask (Real-time)",
    "b3": "Bid (Real-time)",
    "b4": "Book Value",
    "b6": "Bid Size",
    "c": "Change & Percent Change",
    "c1": "Change",
    "c3": "Commission",
    "c6": "Change (Real-time)",
    "c8": "After Hours Change (Real-time)",
    "d": "Dividend/Share",
    "d1": "Last Trade Date",
    "d2": "Trade Date",
    "e": "Earnings/Share",
    "e1": "Error Indication (returned for symbol changed / invalid)",
    "e7": "EPS Estimate Current Year",
    "e8": "EPS Estimate Next Year",
    "e9": "EPS Estimate Next Quarter",
    "f6": "Float Shares",
    "g": "Day's Low h Day's High",
    "j": "52-week Low",
    "k": "52-week High",
    "g1": "Holdings Gain Percent",
    "g3": "Annualized Gain",
    "g4": "Holdings Gain",
    "g5": "Holdings Gain Percent (Real-time)",
    "g6": "Holdings Gain (Real-time)",
    "i": "More Info",
    "i5": "Order Book (Real-time)",
    "j1": "Market Capitalization",
    "j3": "Market Cap (Real-time)",
    "j4": "EBITDA",
    "j5": "Change From 52-week Low",
    "j6": "Percent Change From 52-week Low",
    "k1": "Last Trade (Real-time) With Time",
    "k2": "Change Percent (Real-time)",
    "k3": "Last Trade Size k4 Change From 52-week High",
    "k5": "Percent Change From 52-week High",
    "l": "Last Trade (With Time)",
    "l1": "Last Trade (Price Only)",
    "l2": "High Limit",
    "l3": "Low Limit m Day's Range",
    "m2": "Day's Range (Real-time)",
    "m3": "50-day Moving Average",
    "m4": "200-day Moving Average",
    "m5": "Change From 200-day Moving Average",
    "m6": "Percent Change From 200-day Moving Average",
    "m7": "Change From 50-day Moving Average",
    "m8": "Percent Change From 50-day Moving Average",
    "n4": "Notes",
    "o": "Open",
    "p": "Previous Close",
    "p1": "Price Paid",
    "p2": "Change in Percent",
    "p5": "Price/Sales",
    "p6": "Price/Book",
    "q": "Ex-Dividend Date",
    "r": "P/E Ratio",
    "r1": "Dividend Pay Date",
    "r2": "P/E Ratio (Real-time)",
    "r5": "PEG Ratio",
    "r6": "Price/EPS Estimate Current Year",
    "r7": "Price/EPS Estimate Next Year",
    "s1": "Shares Owned",
    "s7": "Short Ratio",
    "t1": "Last Trade Time",
    "t6": "Trade Links",
    "t7": "Ticker Trend",
    "t8": "1 yr Target Price",
    "v": "Volume",
    "v1": "Holdings Value",
    "v7": "Holdings Value (Real-time)",
    "w": "52-week Range",
    "w1": "Day's Value Change",
    "w4": "Day's Value Change (Real-time)",
    "x": "Stock Exchange",
    "y": "Dividend Yield"
}

if __name__ == "__main__":
    tickers = [
        "INDU", # dow jones industrial average
        "^IXIC", # nasdaq composite
        "^NQUSA", # nasdaq usa
        "^NDX", # nasdaq-100
        "AAPL", # apple
        "SNE", # sony
        "JNJ", # johnson & johnson
        "MSFT" # microsoft
    ]

    # let's just grab all of this crap for now
    flags = [
        "s",
        "n",
        "a",
        "a2",
        "a5",
        "b",
        "b2",
        "b3",
        "b4",
        "b6",
        "c",
        "c1",
        "c3",
        "c6",
        "c8",
        "d",
        "d1",
        "d2",
        "e",
        "e1",
        "e7",
        "e8",
        "e9",
        "f6",
        "g",
        "j",
        "k",
        "g1",
        "g3",
        "g4",
        "g5",
        "g6",
        "i",
        "i5",
        "j1",
        "j3",
        "j4",
        "j5",
        "j6",
        "k1",
        "k2",
        "k3",
        "k5",
        "l2",
        "l3",
        "m2",
        "m3",
        "m4",
        "m5",
        "m6",
        "m7",
        "m8",
        "n4",
        "o",
        "p",
        "p1",
        "p2",
        "p5",
        "p6",
        "q",
        "r",
        "r1",
        "r2",
        "r5",
        "r6",
        "r7",
        "s1",
        "s7",
        "t1",
        "t6",
        "t7",
        "t8",
        "v",
        "v1",
        "w",
        "w1",
        "w4",
        "x",
        "y"
    ]

    baseURL = "http://finance.yahoo.com/d/quotes.csv?s=%s&f=%s"
    output = subprocess.check_output(
        ["curl", "-L", baseURL % ("+".join(tickers), "".join(flags))]
    )

    now = datetime.datetime.utcnow().strftime("%Y%m%d-%H")

    sdb = boto.connect_sdb("access-key", "secret-key")
    domain = sdb.get_domain("stock-data")

    reader = csv.reader(output.strip().split("\n"), delimiter=",", quotechar='"')
    for row in reader:
        # Creates 1 item per run, per symbol. For example, an item with ID MSFT-20111010-11
        # corresponds to data for Microsoft that we obtained on Oct. 10, 2011 @ 11:00 UCT.
        entry = domain.new_item(row[0] + "-" + now)

        for index, flag in enumerate(flags):
            key = options[flag]
            value = row[index]
            entry[key] = value
        
        entry.save()
