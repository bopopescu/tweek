#!/usr/bin/ruby

$doc_hash = {}
$comp_size = 0
$max_size = 0

ARGF.each do |line|
  line = line.split("\t")
  doc_id = line[1]
  temp_score = line[2].to_i
  ref_size = line[3].to_i
  $max_size = [$max_size, ref_size].max
  if $comp_size == 0
    $comp_size = line[4].to_i
  end
  $doc_hash[doc_id] = [temp_score, ref_size]
end

$scores = {}
$doc_hash.each_pair do |doc_id, info|
  temp_score = info[0]
  ref_size = info[1]
  score = temp_score / (($comp_size + ref_size).to_f / $max_size)
  $scores[doc_id] = score
end

$scores = $scores.to_a.sort! { |x, y| y[1] <=> x[1] }
$scores.each do |score|
  puts "#{score[0]}\t#{score[1]}\t#{$doc_hash[score[0]][1]}"
end

