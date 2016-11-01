require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions

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
  setup_game
  erb :hangman
end

post '/hangman' do
  @letter = params[:letter].upcase
  @error_message = check_letter(@letter)
  #session[:used_words] << @letter
  @secret_word = session[:secret_word]
  @letters = session[:used_words]
  @show_word = session[:show_word]
  @turn = session[:turn]
  erb :hangman
end

########### Caesar Cipher ############

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

########### Hangman ############


def setup_game
  words = []
  all_words = File.readlines("5desk.txt")
  all_words.each { |w| words << w.strip if w.strip.length > 4 && w.strip.length < 13 }
  session[:secret_word] = words.sample.upcase
  session[:used_words] = []
  session[:show_word] =  ("_" * session[:secret_word].length).split('')
  session[:turn] = 8
end

def check_letter(letter)
  if letter.length != 1
    return "Type only one character..."
  elsif "ABCDEFGHIJKLMNOPQRSTUVWXYZ".include? letter 
    if session[:show_word].include? letter
      return "Word already used, please try another one."
    else
      word = session[:secret_word].split('')
      word.each_with_index { |x, i| session[:show_word][i] = x if word[i] == letter}
      session[:used_words] << letter
      return letter
    end
  else
    return "Invalid entry, please try again...!"
  end  
end

def play

  while @turn > 0  
    t = read_turn

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
end

def won?
  @hidden_word == @show_word
end
