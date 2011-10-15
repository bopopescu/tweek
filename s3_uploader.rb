#! /usr/local/bin/ruby

require 'rubygems'
require 'aws/s3'
require 'logger'

BUCKET = 'twtr-raw'
ACCESS_KEY = 'access-key'
SECRET_KEY = 'secret-key'
PATH = '/home/ec2-user/tweek/data/'

log = Logger.new('/home/ec2-user/tweek/log/log_s3.txt', shift_age = 'daily')

# get the filename to upload
time = Time.now - 3600
twtr_file = PATH + time.strftime('%Y%m%d-%H') + '.twtr'

# get s3 location to upload to
upload_location = time.strftime('%Y%m%d/%Y%m%d-%H') + '.twtr'

# establish base connection
log.info("Connecting to S3")
AWS::S3::Base.establish_connection!(
  :access_key_id      => ACCESS_KEY, 
  :secret_access_key  => SECRET_KEY
)
log.info("S3 connection established")

# upload to s3
begin
  AWS::S3::S3Object.store(upload_location, open(twtr_file), BUCKET)
  log.info("Upload of #{twtr_file} complete")
rescue Errno::ENOENT
  log.fatal("No such twtr file - #{twtr_file}")
  exit
end

# check that object exists in s3
if AWS::S3::S3Object.exists?(upload_location, BUCKET)
  File.delete(twtr_file)
  log.info("Twtr file successfully saved as #{upload_location}")
else
  log.fatal("Unable to save the file #{twtr_file} to s3//:twtr-raw/#{upload_location}")
end

