require "yaml"
require "FileUtils"


puts "EventManager initialized."


class HangLibrary
  attr_accessor :lib_copy

  def initialize
    @lib_copy = []
  end

  def make_lib
    lines = File.readlines "lib/5desk.txt"
    lines.each do |line|
      rows = line.downcase.split("\r\n")
      @lib_copy.push(rows)
    end
  return @lib_copy.flatten.select!{|word| word.length > 4 && word.length < 13}
  end

end



class Hangman
  attr_accessor :hangman_library, :current_word, :filling, :guess, :current_word
  
  def initialize(hangman_library = HangLibrary.new.make_lib, current_word = '', filling = [], guesses_remaining = 12, guess = "" , letters_guessed = [])
    @hangman_library = hangman_library
    @current_word = current_word
    @filling = filling
    @guess = guess
    @guesses_remaining = guesses_remaining
    @letters_guessed = letters_guessed
  end

  def game_start 
    @current_word = @hangman_library.sample(1).flatten[0]
    @filling = Array.new(current_word.length,"_") 
    if @guesses_remaining == 12
      puts "\nWelcome to hangman..."
      puts "Would you like to load a file?(y/n)"
      load_game_question = gets.chomp
      if load_game_question == 'y'
        puts "What is the name of the game file?"
        game_file = gets.chomp
        puts "\n\n\n\nReturning to saved game!"
        self.class.from_yaml(game_file)
      else
        self.prompt_guess
      end
    end
  end

  def prompt_guess  
    @guess = ''
    puts "\nThe word is a #{@current_word.length} letter word and you have #{@guesses_remaining} guesses left.\n Here are the letters you have guessed so far: #{@letters_guessed} \n Guess a letter!"
    p @filling
    @guess = gets.chomp
    @letters_guessed.push(@guess)
    self.compare_guess
  end

  def compare_guess
    word_to_letter_array = @current_word.split("")
    word_to_letter_array.each_index{|i|  @filling[i] = guess if word_to_letter_array[i] == guess}
    puts "\nLet's check for matches... \n heres the new board!"
    p @filling
    self.display_state
  end

  def display_state
    if @filling == @current_word.split("")
      puts "You win!!!! \n" 
    else
      puts "Would you like to save your game of hangman? (y/n)"
      save_game_question = gets.chomp
      if save_game_question == 'y'
        self.save_game
      elsif @guesses_remaining == 0
        puts "Game over, the word was #{@current_word}"
      else
        @guesses_remaining -= 1
        self.prompt_guess
      end
    end
  end

  def to_yaml
    YAML.dump ({
      :hangman_library => @hangman_library,
      :current_word => @current_word,
      :filling => @filling,
      :guess => @guess,
      :guesses_remaining => @guesses_remaining,
      :letters_guessed => @letters_guessed
    })
  end

  def self.from_yaml(string)
    FileUtils.cd("savestates")
    data = YAML.load_file(string)
    self.new(data[:hangman_library],data[:current_word],data[:filling],data[:guesses_remaining],data[:guess],data[:letters_guessed]).prompt_guess
  end

  def save_game
    p "What would you let to call the save file?"
    filename = gets.chomp
    save_state = self.to_yaml
    FileUtils.cd("savestates") do
    File.open(filename,'w') do |file|
      file.puts save_state
    end
  end
end

end



Hangman.new.game_start