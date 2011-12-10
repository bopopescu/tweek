#!/bin/bash

sudo apt-get install irb1.8 libreadline-ruby1.8 libruby libruby1.8 rdoc1.8 ruby ruby1.8 ruby1.8-dev -qq
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
tar xvfz rubygems-1.8.10.tgz
cd rubygems-1.8.10
sudo ruby setup.rb

sudo gem1.8 install aws-s3

export COMPARE_DOC=20111209-12
export ACCESS_KEY=access_key
export SECRET_KEY=secret_key

exit
