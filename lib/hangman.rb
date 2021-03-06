require 'time'
require 'yaml'

@@dictionary = File.readlines('dictionary.txt')
class Game
    attr_accessor :word, :player_name, :date, :gamespace, :wrong_guesses, :word_guessed_right, :game_number
    def initialize(player_name = "Spy")
        @word = pick_random_word()
        @player_name = player_name
        @date = Time.now
        @gamespace = make_empty_game_space()
        @wrong_guesses = 0
        @word_guessed_right = false
        @game_number = assign_game_number()
    end

    def pick_random_word()
        random_word = ''
        random_word = @@dictionary[rand(@@dictionary.length)].gsub(" ","").gsub("\n","") while 12 < random_word.length || random_word.length < 5
        random_word
    end

    def assign_game_number()
        game = YAML.load_stream(File.open("saved_games.yml",'r'))[-1]
        game == nil ? no = 1 : no = game[:@game_number] + 1
        no
    end

    def make_empty_game_space()
        '_'*(@word.length-1)
    end

    def check_guess(guess)
        is_guess_wrong = true
        letters_of_word = @word.gsub("\n","").downcase.split("")
        letters_of_word.each_with_index do |letter, index|
            if letter == guess
                @gamespace[index] = guess
                is_guess_wrong = false
            end
        end
        @wrong_guesses += 1 if is_guess_wrong
        @word_guessed_right = true unless @gamespace.include?('_')
        exit_game = false
    end

    def save_game()
        game = {}
        instance_variables.each do |var|
            game[var.itself] = instance_variable_get(var)
        end
        File.open('saved_games.yml','a') do |file|
            file.write(game.to_yaml)
        end
        exit_game = true
    end

    def get_guess()
        guess = ''
        puts "\n--------------------------------------------------------------------------"
        until guess.length == 1 || guess == 'save'
            puts "\nYou have #{8-@wrong_guesses} chances left to be wrong, #{@player_name}. Please enter the letter you wanna try."
            puts "You can save the state of your game and continue later too. Type 'save' to do that."
            puts "\nGame Status: #{@gamespace}\n"
            guess = gets.gsub("\n","").downcase
        end
        guess
    end

    def play_round()
        guess = get_guess()
        guess == 'save' ? save_game() : check_guess(guess)
    end

    def play_game()
        exit_game = false
        until @word_guessed_right || @wrong_guesses >= 8 || exit_game == true
            exit_game = play_round()
        end
        if exit_game == true
            puts "The game was saved successfully. You can continue later."
        else 
            @word_guessed_right ? puts("Congratulations, #{@player_name}! You found the word.") : puts("You lost, #{@player_name}.")
            puts "The word was #{@word}"
        end
    end

    def backup_game(game_number)
        games = YAML.load_stream(File.open("saved_games.yml",'r'))
        games.each_with_index do |game,index|
            if game[:@game_number] == game_number
                game.each { |key, value| self.instance_variable_set(key,value) }
            end
        end
        games.reject! {|game| game[:@game_number]==game_number}
        File.open("saved_games.yml", 'w') { |f| f.puts games.map(&:to_yaml) }
        self
    end

    def Game.show_saved_games()
        puts "\n---------------------------Saved Games-------------------------\n"
        YAML.load_stream(File.open("saved_games.yml",'r')).each do |game|
            puts "#{game[:@player_name]}'s game from #{game[:@date]}. Game Number: #{game[:@game_number]}"
        end
        puts "\nPlease enter the game number of the game you want to continue."
    end
end

def welcome()
    puts "Hi, would you like to play a hangman game?"
    answer = gets.gsub("\n", '').downcase
    if answer == 'y' || answer == 'yes'
        until answer == 's' || answer == 'n'
            puts "Would you like to start a new game(type 'n') or continue one of the saved games(type 's')?"
            answer = gets.gsub("\n",'').downcase
            if answer == 's'
                Game.show_saved_games()
                Game.new.backup_game(gets.to_i).play_game()
            elsif answer == 'n'
                puts "What's your name?"
                Game.new(gets.gsub("\n",'')).play_game()
            end
        end
    else
        puts 'OK, bye.'
    end
end

File.open("saved_games.yml", 'w') unless File.exists?("saved_games.yml")
welcome()
