Tweek
====

Description
-----------
Tweek is a research project created to experiment mining Twitter data in a MapReduce framework. This is being built as a senior capstone project at Brown University in the Computer Science course "Data-Intensive Scalable Computing."

Pulling Twitter Data
--------------------
The script used to stream Twitter information and store it in a file is [curl_catcher.sh][curl_catcher]. Replace `$TWITTER_USER` and `$TWITTER_PASS` with the username and password to a Twitter account. This script runs for five minutes (the `-m 300` option), and appends the data to hourly files named in the format `YYYYMMDD-HH.twtr` in `tweek/data`. To pull Twitter data continuously, simply add the following line to your crontab:

`*/5 * * * * /path/to/tweek/curl_catcher.sh`

Uploading Twitter Data to S3
----------------------------
The hourly raw Twitter data is uploaded to Amazon's S3 service every hour, five minutes past the hour, using [s3_uploader.rb][s3_uploader]. This script looks for the .twtr file from the previous hour, attempts to upload it to s3, and deletes the file locally if the upload is successful. The cron job for this looks like the following line:

`5 * * * * /usr/bin/ruby /path/to/tweek/s3_uploader.rb &> /dev/null`


[curl_catcher]: https://github.com/mgartner/tweek/blob/master/curl_catcher.sh
[s3_uploader]: https://github.com/mgartner/tweek/blob/master/s3_uploader.rb
