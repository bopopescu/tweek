Tweek
====

Description
-----------
Tweet is a research project created to experiment mining Twitter data in a MapReduce framework. More coming soon...
[rake]: https://github.com/jimweirich/rake

Pulling Twitter Data
--------------------
The script used to stream Twitter information and store it in a file is [curl_catcher.sh][curl_catcher]. Replace `$TWITTER_USER` and `$TWITTER_PASS` with the username and password to a Twitter account. This script runs for five minutes (the `-m 300` option), and appends the data to hourly files named in the format `YYYYMMDD-HH.twtr` in `tweek/data`. To have Twitter data being pulled continuously, simply add the following line to your crontab:

`*/5 * * * * /path/to/tweek/curl_catcher.sh`

Uploading Twitter Data to S3
----------------------------
The hourly raw Twitter data to Amazon's S3 service every hour, five minutes past the hour, using [s3_uploader.rb][s3_uploader]. The crontab line for this looks like the following line:

`5 * * * * /usr/bin/ruby /path/to/tweek/s3_uploader.rb &> /dev/null`


[curl_catcher]: https://github.com/mgartner/tweek/blob/master/curl_catcher.sh
[s3_uploader]: https://github.com/mgartner/tweek/blob/master/s3_uploader.rb
