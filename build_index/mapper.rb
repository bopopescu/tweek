#!/usr/bin/ruby

# This Mapper is responsible for parsing each raw tweet and outputing
# tuples of (doc_id, size) and (doc_id, word, count).

require 'set'
require 'rubygems'
require 'crack'
require 'whatlanguage'
require './stemmable.rb'

MIN_WORD_SIZE = 3
STOP_LIST = Set.new(['a', 'about', 'are', 'an', 'as', 'at', 'be', 'but', 
                     'by', 'for', 'from', 'has', 'have', 'he', 'her', 
                     'his', 'in', 'is', 'it', 'its', 'more', 'new', 'of', 
                     'on', 'one', 'said', 'say', 'that', 'the', 'their', 
                     'they', 'this', 'to', 'was', 'which', 'who', 'will', 
                     'with', 'you'])

class String
  include Stemmable
end

# A hash of {doc_id => {word => count}} for in-mapper combining.
$word_count = {}

# Adds count to the value at $word_count[doc_id][word]
def add_to_word_count(doc_id, word, count)
  if $word_count.key?(doc_id)
    if $word_count[doc_id].key?(word)
      $word_count[doc_id][word] = $word_count[doc_id][word] + count
    else
      $word_count[doc_id][word] = count
    end
  else
    $word_count[doc_id] = {word => count}
  end
end

# Processing for each tweet
ARGF.each do |line|
  tweet = line.strip

  unless tweet.empty? || tweet.length == 0
    begin

      parsed_tweet = Crack::JSON.parse(tweet)
      text = parsed_tweet['text']
      doc_id = Time.parse(parsed_tweet['created_at']).utc.strftime('%Y%m%d-%H')

      if text.language == :english
        words = text.split(/\W+/)

        words.each do |word|
          word = word.downcase
          unless STOP_LIST.include?(word) || word.length < MIN_WORD_SIZE
            word = word.stem
            add_to_word_count(doc_id, word, 1)
          end
        end
      end
    rescue
      # couldn't parse tweet
    end
  end
end

$word_count.each_pair do |doc_id, word_hash|
  word_hash.each_pair do |word, count|
    puts "#{doc_id}\t#{word}\t#{count}"
  end
end

