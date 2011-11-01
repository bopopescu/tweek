#!/bin/bash

#sudo apt-get -y safe-upgrade
#sudo apt-get -y install unzip build-essential git-core ia32-libs
#sudo apt-get -y -t universe install ruby rubygems ruby-dev

sudo apt-get update
sudo apt-get install ruby1.8-dev
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
tar xvfz rubygems-1.8.10.tgz
cd rubygems-1.8.10 && sudo ruby setup.rb

sudo gem update --system
sudo gem install hoe
sudo gem install crack --source http://rubygems.org
sudo gem install whatlanguage

exit
