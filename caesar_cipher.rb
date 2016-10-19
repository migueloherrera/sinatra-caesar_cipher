require 'sinatra'

get '/' do
  erb :index
end

post '/' do
  @string = caesar_cipher(params[:text], params[:shift_factor].to_i)
  erb :index
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
