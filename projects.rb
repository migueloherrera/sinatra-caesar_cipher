require 'sinatra'

get '/' do
  erb :index
end

get '/caesar_cipher' do
  erb :caesar_cipher
end

post '/caesar_cipher' do
  @string = caesar_cipher(params[:text], params[:shift_factor].to_i)
  erb :caesar_cipher
end

get '/hangman' do
  @secret_word = setup_game
  erb :hangman
end

post '/hangman' do
  @letter = params[:letter]
  erb :hangman
end

def caesar_cipher(string, shift_factor)
  lower = 'abcdefghijklmnopqrstuvwxyz'
  upper = lower.upcase

  string.length.times do |p|
  
    # if current letter is lowercase 
    string[p] = lower[(lower.index(string[p]) + shift_factor) % 26] if lower.include? string[p]
    # if current letter is uppercase
    string[p] = upper[(upper.index(string[p]) + shift_factor) % 26] if upper.include? string[p]
  
  end
  # returns the modified string
  string

end

require 'yaml'

class Hangman
  
  def initialize(words)
    @words = words
    start
  end

  private
  def play
    @hidden_word = @words.sample.upcase.split('')
    @used_words = []

    @show_word =  ("_" * @hidden_word.length).split('')
    puts "#{@show_word.join(' ')}"
    @turn = 8
    while @turn > 0  
      t = read_turn
      save_game if t == "#"

      if @hidden_word.include? t
        @hidden_word.each_with_index { |x, i| @show_word[i] = x if @hidden_word[i] == t}
        if won?
          puts "---> #{@show_word.join} <---"
          puts "\n* * * * * *  You Won!  * * * * * *"
          break
        end  
      else
        @turn -= 1
      end
      puts "#{@show_word.join(" ")}     Turns left: #{@turn}     Words used: #{@used_words.join(" ")}"
    end
 
    puts "\nYou lost!  The secret word was: #{@hidden_word.join}\n" if !won? 
    play_again? ? start : exit
  end
  
  def play_again?
    print "\nDo you want to play again (y/n)?: "
    gets.chomp.upcase == "Y"? true : false
  end
  
  def won?
    @hidden_word == @show_word
  end
  
  def read_turn
    while true
      print "\n(To save the game enter '#' )    Guess a letter: "
      @guess = gets.chomp.upcase
      if @guess.length != 1
        puts "\nType only one character and press enter..."
      elsif "ABCDEFGHIJKLMNOPQRSTUVWXYZ#".include? @guess 
        if @show_word.include? @guess
          puts "\nWord already used, please try another one."
        else
          break
        end
      else
        puts "\nInvalid entry, please try again...!"
      end
    end  
    @used_words << @guess if @guess != "#"
    puts @guess
    @guess
  end

  def start
    puts "\n... Play Hangman ..."
    puts "  1. New Game"
    puts "  2. Load Game"
    puts "  3. Exit"
    print "Choose an option from 1 to 3: "
    option = gets.chomp.to_i
    case option
    when 1
      play
    when 2
      load_game
    when 3
      exit
    end
  end
  
end

def setup_game
  words = []
  all_words = File.readlines("5desk.txt")
  all_words.each { |w| words << w.strip if w.strip.length > 4 && w.strip.length < 13 }
  words.sample
end
