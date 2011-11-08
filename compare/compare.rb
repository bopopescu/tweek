#!/usr/bin/ruby
# compare.rb
# This file is responsible for comparing a sample to reference of samples.
# It gives a detailed output of the most similar samples.
# Usage: ruby compare.rb /path/to/comparee/directory /path/to/reference


#TODO: pull files straight from s3 to make this soooo much easier!
require 'rubygems'
require 'aws/s3'

COMPAREE = ARGV[0]
REFERENCE = ARGV[1]

BUCKET = 'twtr-index-output'
ACCESS_KEY = 'access_key'
SECRET_KEY = 'secret_key'

# establish base connection
AWS::S3::Base.establish_connection!(
  :access_key_id      => ACCESS_KEY,
  :secret_access_key  => SECRET_KEY
)

comparee_files = Bucket.objects(BUCKET, :prefix => COMPAREE)
reference_files = Bucket.objects(BUCKET, :prefix => REFERENCE)

$comparee_hash = {}
$reference_hash = {}

# Collect COMPAREE sample data.
comparee_files.each do |s3_file|
  data = s3_file.value
  data.each_line do |line|
    line = line.split(';')

    # create initital hash
    doc_id = line.shift
    $comparee_hash[doc_id] = {}

    # add size to hash
    size = line.shift.to_i
    $comparee_hash[doc_id][:size] = size

    # add each word-count pair to hash
    line.each do |word_count|
      word_count.split(':')
      word = word_count[0]
      count = word_count[1].to_i
      $comparee_hash[doc_id][word] = count
    end
  end
end

# Alert user if COMPAREE contains more than one sample
if $comparee_hash.size > 1
  puts "WARNING: COMPAREE contains #{$comparee_hash.size} samples; expecting only 1."
end

# Collect REFERENCE samples.
reference_files.each do |s3_file|
  data = s3_file.value
  data.each_line do |line|
    line = line.split(';')

    # add sample to hash
    doc_id = line[0]
    $reference_hash[doc_id] = {}

    # add size to hash
    size = line[1].to_i
    $reference_hash[doc_id][:size] = size

    # drop first two array elements (doc_id, size)
    line.drop(2)

    # add each word-count pair to hash
    line.each do |word_count|
      word_count.split(':')
      word = word_count[0]
      count = word_count[1].to_i
      $reference_hash[doc_id][word] = count
    end
  end
end

puts "NOTE: REFERENCE contains #{$reference_hash.size} samples."

$scores = {}

$reference_hash.each_pair do |doc_id, word_hash|
  comp_word_hash = $comparee_hash[$comparee_hash.keys.first]
  common_words = word_hash.keys & comp_word_hash.keys

  score = 0
  common_words.each do |word|
    score += (1 + Math.log(comp_word_hash[word])) / comp_word_hash[:size]
    score += (1 + Math.log(word_hash[word])) / word_hash[:size]
  end
  $scores[doc_id] = score
end

# ouput most common samples from reference
$scores = $scores.to_a.sort_by! { |score| score[1] }
$scores.each do |score|
  puts "#{score[0]}\t#{score[1]}"
end

