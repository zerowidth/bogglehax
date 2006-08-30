require 'irc/plugin'

require 'enumerator' # each_slice

require 'board_hack'

class BoggleHax < IRC::Plugin
  def initialize(client)
    super(client)
    @game_channel = @client.config[:game_channel]
    @game_bot = @client.config[:game_bot]
    
    @wordlist = File::readlines('words.txt').map { |word| word.scan(/[a-pr-z]|qu/) }
    logger.info "loaded #{@wordlist.size} words"
    
    @mode = @client.config[:hack_mode] || :nice # :mean, :informative
  end
  
  def registered_with_server
    @client.send_raw("JOIN #{@game_channel}")
  end
  
  def channel_message(chan, msg, who)
    if who.nick == @game_bot
      
      case msg
      when /Starting new game/
        # @client.channel_message(@game_channel, 'yay game is starting')
        logger.info "detected game start"
        @board = []
        @words = []
      when /^\002([A-PR-Z]\s|Qu){5}/
        logger.info "board line detected"
        @board += msg.gsub(/\002|\s/,'').scan /[A-PR-Z]|Qu/ if @board.size < 25
        @words = hack_words if @board.size == 25
        
      when /WINNER: #{@client.state[:nick]}/
        messages = [
          "haha! i made all you punk bitches suck it down!",
          "sukkit, trebek! suck it long, and suck it hard!",
          "<nelson>haw haw</nelson>",
          "i love the smell of napalm in the morning",
          "duffman says, OH YEAH!",
          "i got 99 problems but my score ain't one",
          "\001ACTION pisses on your grandmother's grave\001",
          "i'm ssssssmokin'!",
          "HE. COULD. GO. ALL. THE. WAY!",
          "i'm here to kick ass and chew bubble gum. and i'm all out of gum.",
          "\001ACTION giggles, 'did i do that?'\001",
          "there's a party in my pants, and you're all invited!",
          "this must be the shallow end of the gene pool",
          "how did you all get here, the short bus?",
        ]
        which = rand(messages.size)
        @client.channel_message(@game_channel, messages[which]) if @mode == :mean

      when /(WINNER|TIE):/
        @client.channel_message(@game_channel, "did you find #{@words.first(5).join(', ')}?") if @mode == :informative
      end

    else # messages from everyone else
      
      case msg
      when /#{@client.state[:nick]}.*help/
        @client.channel_message(@game_channel, "you can tell me to be nice, be mean, be informative, or shut up")
      when /#{@client.state[:nick]}.*be (nice|mean|informative)/
        @mode = $1.to_sym
        @client.channel_message(@game_channel, "ok, i'll be #{$1}")
      when /#{@client.state[:nick]}.*shut up/
        @mode = nil
        @client.channel_message(@game_channel, "ok, i'll shut my dirty mouth")
      when /#{@client.state[:nick]}.*what/ # what are you?
        being = @mode ? @mode.to_s : 'quiet'
        @client.channel_message(@game_channel, "i am being #{being}" )
      end

    end
  end
  
  private
  
  def hack_words
    return unless @mode
    
    # @client.channel_message(@game_channel, 'got board: ' + @board.join(', '))
    # @client.channel_message(@game_channel, 'hacking...')
    
    logger.info "board found, beginning hack"
    board = BoardHack.new( @board.map {|char| char.downcase} )
    potentials = @wordlist.find_all { |word| board.could_include? word }.sort_by { |word| word.length }.reverse
    logger.info "found #{potentials.size} potential words, searching board"
    
    found = []
    potentials.each { |word| found << word if board.include?(word) }
    
    
    if found.empty? 
      # @client.channel_message(@game_channel, "didn't find any words :(")
    else
      found.map! {|word_arr| word_arr.join }
      # @client.channel_message(@game_channel, "try these on for size: #{found.first(5).join(', ')}")
      
      if @mode == :mean
        found.each_slice(20) do |slice|
          @client.private_message @game_bot, slice.join(' ')
          sleep(0.2)
        end
      elsif @mode == :nice
        @client.private_message @game_bot, found.first(3).join(' ')
      end
      
    end
    
    @words = found
    
  end
  
end