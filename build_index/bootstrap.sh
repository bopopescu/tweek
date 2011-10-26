#!/bin/bash

sudo apt-get update
sudo apt-get -y safe-upgrade
sudo apt-get -y install unzip build-essential git-core ia32-libs
sudo apt-get -y -t universe install ruby rubygems ruby-dev

sudo gem install hoe
sudo gem install crack --source http://rubygems.org
sudo gem install whatlanguage

exit
