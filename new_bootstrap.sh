#!/bin/bash

sudo apt-get install irb1.8 libreadline-ruby1.8 libruby libruby1.8 rdoc1.8 ruby ruby1.8 ruby1.8-dev -qq
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
tar xvfz rubygems-1.8.10.tgz
cd rubygems-1.8.10
sudo ruby setup.rb

sudo gem1.8 install hoe --source http://rubygems.org
sudo gem1.8 install yajl-ruby --source http://rubygems.org
sudo gem1.8 install whatlanguage --source http://rubygems.org
sudo gem1.8 install aws-s3 --source http://rubygems.org

export PLACE_HOLDER=place_holder

exit
