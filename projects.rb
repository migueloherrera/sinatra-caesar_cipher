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
  @show_word = session[:show_word]
  erb :hangman
end

post '/hangman' do
  @letter = params[:letter].upcase
  @error_message = check_letter(@letter)
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
    if (session[:show_word].include? letter) || (session[:used_words].include? letter)
      return "Word already used, please try another one."
    elsif !session[:secret_word].include? letter
      session[:used_words] << letter
      session[:turn] = session[:turn].to_i - 1
      session[:turn] <= 0 ? "you lost!" : "One less chance"
    else
      word = session[:secret_word].split('')
      word.each_with_index { |x, i| session[:show_word][i] = x if word[i] == letter}
      session[:used_words] << letter
      won? ? "you won!" : letter
    end
  else
    return "Invalid entry, please try again...!"
  end  
end

def won?
  guess = session[:show_word].join
  session[:secret_word] == guess
end
