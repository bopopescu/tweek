# This Reducer consumes input in the format:
#   1. <doc_id> <word> <count>

# The doc_hash that keeps track of word counts and size of the doc.
$doc_hash = {}

# Updates the $doc_hash by adding count to the given word in the
# given document, and incrementing the size of the document.
def add_to_doc_hash(doc_id, word, count)
  if $doc_hash.key?(doc_id)
    $doc_hash[doc_id][:size] += count
    if $doc_hash.key?(word)
      $doc_hash[word] += count
    else
      $doc_hash[word] = count
    end
  else
    $doc_hash[doc_id] = {}
    $doc_hash[doc_id][:size] = count
    $doc_hash[doc_id][word] = count
  end
end

ARGF.each do |line|
  split = line.split("\t")
  doc_id = line[0]
  word = line[1]
  count = line[2].to_i
  add_to_doc_hash(doc_id, word, count)
end

#TODO: print out in a formatted index of some kind
#word_count_hash.each_pair do |doc_id, word_hash|
#  word_hash.each_pair do |word, count|
#    puts "#{doc_id}\tW\t#{word}\t#{count}"
#  end
#end
