require 'board_hack'

words = File::readlines('words.txt')
words = words.map { |word| word.scan(/[a-pr-z]|qu/) }
puts "#{words.size} words loaded"

# T H G I F 
# O S R S V 
# Z A L R I 
# A N O C I 
# T I D E U
board = "T, H, G, I, F, O, S, R, S, V, Z, A, L, R, I, A, N, O, C, I, T, I, D, E, U".gsub(',','').downcase.split
board = BoardHack.new(board)

# word = %w{a n a l c}
# p board.include? word
# p word
# p board.board.size

words = words.find_all { |word| board.could_include? word }.sort_by { |word| word.length }.reverse#[0..999]
puts "reduced to #{words.size} potential words by basic array subtraction"

good = []
words.each { |word| good << word if board.include?(word) }

puts "found #{good.size} words on the board"

good.each { |word| puts word.join('') }



# c = ["c", "o", "u", "n", "t", "e", "r", "r", "e", "v", "o", "l", "u", "t", "i", "o", "n", "a", "r", "i", "e", "s"]
# p contains?(board, %w{ a a r d v a r})
# p c - board
# 


# p words[0..9]

# require 'board_hack'


# p board