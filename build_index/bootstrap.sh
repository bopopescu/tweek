#!/bin/bash

sudo apt-get update
sudo apt-get -y install rubygems
sudo gem install crack --source http://rubygems.org
sudo gem install whatlanguage

exit
