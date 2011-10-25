#!/usr/bin/ruby

# This Mapper is responsible for parsing each raw tweet and outputing
# tuples of (doc_id, size) and (doc_id, word, count).

require 'set'
require 'rubygems'
require 'crack'
require 'whatlanguage'

####################################################################
## STEMMABLE #######################################################
####################################################################
# This is included in the mapper script because there is not gem to 
# bootstrap a worker node with this required code.

module Stemmable

  STEP_2_LIST = {
    'ational'=>'ate', 'tional'=>'tion', 'enci'=>'ence', 'anci'=>'ance',
    'izer'=>'ize', 'bli'=>'ble',
    'alli'=>'al', 'entli'=>'ent', 'eli'=>'e', 'ousli'=>'ous',
    'ization'=>'ize', 'ation'=>'ate',
    'ator'=>'ate', 'alism'=>'al', 'iveness'=>'ive', 'fulness'=>'ful',
    'ousness'=>'ous', 'aliti'=>'al',
    'iviti'=>'ive', 'biliti'=>'ble', 'logi'=>'log'
  }
  
  STEP_3_LIST = {
    'icate'=>'ic', 'ative'=>'', 'alize'=>'al', 'iciti'=>'ic',
    'ical'=>'ic', 'ful'=>'', 'ness'=>''
  }


  SUFFIX_1_REGEXP = /(
                    ational  |
                    tional   |
                    enci     |
                    anci     |
                    izer     |
                    bli      |
                    alli     |
                    entli    |
                    eli      |
                    ousli    |
                    ization  |
                    ation    |
                    ator     |
                    alism    |
                    iveness  |
                    fulness  |
                    ousness  |
                    aliti    |
                    iviti    |
                    biliti   |
                    logi)$/x


  SUFFIX_2_REGEXP = /(
                      al       |
                      ance     |
                      ence     |
                      er       |
                      ic       | 
                      able     |
                      ible     |
                      ant      |
                      ement    |
                      ment     |
                      ent      |
                      ou       |
                      ism      |
                      ate      |
                      iti      |
                      ous      |
                      ive      |
                      ize)$/x


  C = "[^aeiou]"         # consonant
  V = "[aeiouy]"         # vowel
  CC = "#{C}(?>[^aeiouy]*)"  # consonant sequence
  VV = "#{V}(?>[aeiou]*)"    # vowel sequence

  MGR0 = /^(#{CC})?#{VV}#{CC}/o                # [cc]vvcc... is m>0
  MEQ1 = /^(#{CC})?#{VV}#{CC}(#{VV})?$/o       # [cc]vvcc[vv] is m=1
  MGR1 = /^(#{CC})?#{VV}#{CC}#{VV}#{CC}/o      # [cc]vvccvvcc... is m>1
  VOWEL_IN_STEM   = /^(#{CC})?#{V}/o                      # vowel in stem

  #
  # Porter stemmer in Ruby.
  #
  # This is the Porter stemming algorithm, ported to Ruby from the
  # version coded up in Perl.  It's easy to follow against the rules
  # in the original paper in:
  #
  #   Porter, 1980, An algorithm for suffix stripping, Program, Vol. 14,
  #   no. 3, pp 130-137,
  #
  # See also http://www.tartarus.org/~martin/PorterStemmer
  #
  # Send comments to raypereda@hotmail.com
  #
  
  def stem_porter

    # make a copy of the given object and convert it to a string.
    w = self.dup.to_str
    
    return w if w.length < 3
    
    # now map initial y to Y so that the patterns never treat it as vowel
    w[0] = 'Y' if w[0] == ?y
    
    # Step 1a
    if w =~ /(ss|i)es$/
      w = $` + $1
    elsif w =~ /([^s])s$/ 
      w = $` + $1
    end

    # Step 1b
    if w =~ /eed$/
      w.chop! if $` =~ MGR0 
    elsif w =~ /(ed|ing)$/
      stem = $`
      if stem =~ VOWEL_IN_STEM 
        w = stem
	case w
        when /(at|bl|iz)$/             then w << "e"
        when /([^aeiouylsz])\1$/       then w.chop!
        when /^#{CC}#{V}[^aeiouwxy]$/o then w << "e"
        end
      end
    end

    if w =~ /y$/ 
      stem = $`
      w = stem + "i" if stem =~ VOWEL_IN_STEM 
    end

    # Step 2
    if w =~ SUFFIX_1_REGEXP
      stem = $`
      suffix = $1
      # print "stem= " + stem + "\n" + "suffix=" + suffix + "\n"
      if stem =~ MGR0
        w = stem + STEP_2_LIST[suffix]
      end
    end

    # Step 3
    if w =~ /(icate|ative|alize|iciti|ical|ful|ness)$/
      stem = $`
      suffix = $1
      if stem =~ MGR0
        w = stem + STEP_3_LIST[suffix]
      end
    end

    # Step 4
    if w =~ SUFFIX_2_REGEXP
      stem = $`
      if stem =~ MGR1
        w = stem
      end
    elsif w =~ /(s|t)(ion)$/
      stem = $` + $1
      if stem =~ MGR1
        w = stem
      end
    end

    #  Step 5
    if w =~ /e$/ 
      stem = $`
      if (stem =~ MGR1) ||
          (stem =~ MEQ1 && stem !~ /^#{CC}#{V}[^aeiouwxy]$/o)
        w = stem
      end
    end

    if w =~ /ll$/ && w =~ MGR1
      w.chop!
    end

    # and turn initial Y back to y
    w[0] = 'y' if w[0] == ?Y

    w
  end


  #
  # make the stem_porter the default stem method, just in case we
  # feel like having multiple stemmers available later.
  #
  alias stem stem_porter

end

####################################################################
## MAPPER CODE #####################################################
####################################################################

MIN_WORD_SIZE = 3
STOP_LIST = Set.new(['a', 'about', 'are', 'an', 'as', 'at', 'be', 'but', 
                     'by', 'for', 'from', 'has', 'have', 'he', 'her', 
                     'his', 'in', 'is', 'it', 'its', 'more', 'new', 'of', 
                     'on', 'one', 'said', 'say', 'that', 'the', 'their', 
                     'they', 'this', 'to', 'was', 'which', 'who', 'will', 
                     'with', 'you'])

# Give the String class the .stem() method.
class String
  include Stemmable
end

# A hash of {doc_id => {word => count}} for in-mapper combining.
$word_count = {}

# Adds count to the value at $word_count[doc_id][word]. This is
# used for in-mapper combining.
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

# Process each tweet.
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

# Output tuples of (doc_id, word, count)
$word_count.each_pair do |doc_id, word_hash|
  word_hash.each_pair do |word, count|
    puts "#{doc_id}\t#{word}\t#{count}"
  end
end

