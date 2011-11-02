#! /usr/local/bin/ruby

require 'rubygems'
require 'aws/s3'

twtr_file = ARGV[0].to_s

upload_location = twtr_file.split('/').last
upload_location = upload_location.split('-').first + '/' + upload_location

BUCKET = 'twtr-raw'
ACCESS_KEY = 'access-key'
SECRET_KEY = 'secret-key'
PATH = '/home/ec2-user/tweek/data/'

# establish base connection
AWS::S3::Base.establish_connection!(
  :access_key_id      => ACCESS_KEY, 
  :secret_access_key  => SECRET_KEY
)

# upload to s3
AWS::S3::S3Object.store(upload_location, open(twtr_file), BUCKET)

# check that object exists in s3
if AWS::S3::S3Object.exists?(upload_location, BUCKET)
  File.delete(twtr_file)
end

