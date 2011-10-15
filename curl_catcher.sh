#! /bin/sh

curl --silent -m 300 https://stream.twitter.com/1/statuses/sample.json -u$TWITTER_USER:$TWITTER_PASS >> /home/ec2-user/tweek/data/$(date +%Y%m%d-%H).twtr
