class BoardHack
  
  attr_reader :board
  
  def initialize(board)
    @board = board #create_board(board_id)
    @board_size = 5
  end
  
  def could_include?(word_array)

    container = board.dup
    contained = word_array.dup

    until contained.empty? do
      thing = contained.shift
      idx = container.index(thing)
      return false unless idx
      container.delete_at(idx)
    end

    true  
  end
  
  def include?(word_array)
    find_word word_array
  end
  
  private
  
  # ----- board search -----

  # recursive search:
  def find_word(word_array, visited=[], location=nil)
    # recursion end condition
    return true if word_array.size == 0 # easy case, empty words exist everywhere!
    word_array = word_array.dup

    cube = word_array.shift # get the first letter on the list
    
    locations = find_cube(cube, visited, location) # potential search locations
    
    found = false
    locations.each do |location|
      new_word = word_array.dup
      new_visited = visited.dup
      new_visited[location] = true
      found ||= find_word(new_word, new_visited, location) # recursive call
    end

    found
  end

  def find_cube(cube, visited, adjacent_to)
    found = []
    @board.each_with_index do |val, key|
      found << key if val == cube && !visited[key] && adjacent?(key, adjacent_to)
    end
    found
  end

  def adjacent? (key1, key2)
    return true unless key1 && key2 # any key is adjacent to nothingness! (nil)
    # do the search for key2 around key1 in a square grid
    key1x = key1 % @board_size # get the x position in the grid
    key1y = (key1-key1x) / @board_size # and the y position
    key2x = key2 % @board_size # x position of second key
    key2y = (key2-key2x) / @board_size # y position of second key
    # if the key x/y positions are within 1 of each other, then key2 is
    # in one of the 9 positions surrounding key1 (does not wrap!)
    (key1x-key2x).abs <= 1 && (key1y-key2y).abs <= 1 
  end
  
end

if __FILE__ == $0
  b = BoardHack.new %w{
    i e a d r
    s z n e d
    n r o a c
    a u e e s
    p a d o o
  }
  
end