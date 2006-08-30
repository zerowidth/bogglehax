require 'enumerator' # for each_slice
require 'process_manager'

CUBES = [ # for a 5x5 game
  %w{f y i p r s},
  %w{p t e l c i},
  %w{o n d l r h},
  %w{h h d l o r},
  %w{r o r v g w},
  %w{m e e e e a},
  %w{a e a e e e},
  %w{a a a f s r},
  %w{t c n e c s},
  %w{s a f r a i},
  %w{c r s i t e},
  %w{i i t e i t},
  %w{o n t d d h},
  %w{m a n n g e},
  %w{t o t t e m},
  %w{h o r d n l},
  %w{d e a n n n},
  %w{t o o o t u},
  %w{b k j x qu z},
  %w{c e t l i i},
  %w{s a r i f y},
  %w{r i r p y r},
  %w{u e g m a e},
  %w{s s s n e u},
  %w{n o o w t u}
]

histogram = Hash.new(0)
CUBES.each do |cube|
  cube.each do |char|
    histogram[char] += 1
  end
end

histogram = histogram.sort {|a,b| a[1] <=> b[1] }
HISTOGRAM = histogram

def word_possible?(word)
  word = word.scan(/[a-pr-z]|qu/)
  # sorted so words like 'earthquake' don't take for freakin' ever
  word = word.sort {|a,b| HISTOGRAM.assoc(a)[1] <=> HISTOGRAM.assoc(b)[1]}
  word_in_cubes? word, CUBES.dup
end

def word_in_cubes?(word_array, cubes)
  # puts "word array: #{word_array.inspect}"
  return true if word_array.empty?
  
  potentials = []
  search = word_array.shift
  # puts "searching for #{search}"
  cubes.each do |cube|
    potentials << cube if cube.include? search
  end
  
  possible = false
  # puts "#{potentials.size} potential cubes out of #{cubes.size}: #{potentials.inspect}"
  potentials.each do |potential|
    break if possible # skip any further checking if it's been found
    # (25-cubes.size).times { print "-"}
    # puts "possible cube: #{potential.inspect}"
    possible = word_in_cubes?(word_array.dup, cubes - [potential] )
  end

  possible
end

words = File::readlines('words-orig.txt')

words.map! {|word| word.strip }

candidates = []

words.each do |word|
  next if word.size < 4
  next if word =~ /[A-Z]/ # no capitalized words
  next unless word =~ /^[a-z]+$/ # no punctuation
  candidates << word
end

# candidates = candidates[0..1999]
candidates.sort!

results = []
candidates.each { |word| results << word if word_possible? word }

# slices = []
# candidates.each_slice(2000) { |slice| slices << slice }
# results = ProcessManager.process(slices, 3) { |slice|
#   final = []
#   slice.each { |word| final << word if word_possible? word }
#   final.each { |word| puts word } # return to parent process for gathering
# }

puts "#{words.size} words loaded"
puts "#{candidates.size} candidates"
puts "#{results.size} valid words"

File.open('words.txt', 'w') do |file|
  results.each { |result| file.puts result }
end