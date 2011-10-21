#!/usr/bin/ruby

# This Reducer consumes input in the format:
#   1. <doc_id> <word> <count>

# The doc_hash that keeps track of word counts and size of the doc.
$doc_hash = {}

# Updates the $doc_hash by adding count to the given word in the
# given document, and incrementing the size of the document.
def add_to_doc_hash(doc_id, word, count)
  if $doc_hash.key?(doc_id)
    $doc_hash[doc_id][:size] += count
    if $doc_hash[doc_id].key?(word)
      $doc_hash[doc_id][word] += count
    else
      $doc_hash[doc_id][word] = count
    end
  else
    $doc_hash[doc_id] = {}
    $doc_hash[doc_id][:size] = count
    $doc_hash[doc_id][word] = count
  end
end

# Processing for each line from the mappers.
ARGF.each do |line|
  split = line.split("\t")
  doc_id = split[0]
  word = split[1]
  count = split[2].to_i
  add_to_doc_hash(doc_id, word, count)
end

# Prints out the final index.
# TODO: this may have to be re-done if calling eval() on the entire 
# string representation of the hash will bottle neck the system from
# lack of sufficient memory.
puts $doc_hash
#$doc_hash.each_pair do |doc_id, word_hash|  
  # TODO:
#end
