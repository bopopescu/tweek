#!/usr/bin/ruby

# This mapper calculates the temporary score for each
# document pair.

require 'rubygems'
require 'aws/s3'

CONSTANT = 1

COMPARE_DOC = ENV['COMPARE_DOC']
BUCKET = 'twtr-index-output'
ACCESS_KEY = ENV['ACCESS_KEY']
SECRET_KEY = ENV['SECRET_KEY']

AWS::S3::Base.establish_connection!(
  :access_key_id     => ACCESS_KEY,
  :secret_access_key => SECRET_KEY
)

compare_files = AWS::S3::Bucket.objects(BUCKET, :prefix => COMPARE_DOC)

$compare_hash = {}

# Collect COMPAREE sample data.
compare_files.each do |s3_file|
  data = s3_file.value
  data.each_line do |line|
    line = line.split(';')

    # create initital hash
    doc_id = line.shift
    $compare_hash[doc_id] = {}

    # add size to hash
    size = line.shift.to_i
    $compare_hash[doc_id][:size] = size

    # add each word-count pair to hash
    line.each do |word_count|
      word_count = word_count.split(':')
      word = word_count[0].strip
      if !word.empty?
        count = word_count[1].to_i
        $compare_hash[doc_id][word] = count
      end
    end
  end
end

# Alert user if COMPAREE contains more than one sample
$compare_key = COMPARE_DOC
if $compare_hash.size > 1
  $compare_hash.each_key do |sample|
    if sample == COMPARE_DOC
      $compare_key = sample
    end
  end
end

$compare_words = $compare_hash[$compare_key]
$compare_size = $compare_words[:size]

# Calculate score for each reference document.
ARGF.each do |line|
  line = line.split(';')

  doc_id = line[0]
  size = line[1].to_i

  line = line.drop(2)

  reference_words = {}
  line.each do |word_count|
    word_count = word_count.split(':')
    word = word_count[0].strip
    if !word.empty?
      count = word_count[1].to_i
      reference_words[word] = count
    end
  end

  common_words = $compare_words.keys & reference_words.keys
  
  temp_score = 0
  common_words.each do |word|
    temp_score += $compare_words[word]
    temp_score += reference_words[word]
  end

  # Output the tuple to be sent to the reducer.
  # NOTE: CONSTANT is used so that all tuples are sent
  # to 1 reducer.
  puts "#{CONSTANT}\t#{doc_id}\t#{temp_score}\t#{size}\t#{$compare_size}"

end
