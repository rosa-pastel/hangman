require 'time'
@@dictionary = File.readlines('dictionary.txt')
class Game
    def initialize(player_name = "Spy")
        @word = pick_random_word()
        @player_name = player_name
        @date = Time.now
        @gamespace = ''
        @wrong_guesses = 0
        @word_guessed_right = false
    end

    def pick_random_word()
        random_word = ''
            while random_word.length < 5 || random_word.length > 12
                random_number = rand(@@dictionary.length)
                random_word = @@dictionary[random_number]
            end
        random_word
    end

    def make_empty_game_space()
        @word.length.times do 
            @gamespace += '_'
        end
    end

    def play_round()
        guess = ''
        is_guess_wrong = true
        puts "\n--------------------------------------------------------------------------"
        until guess.length == 1
            puts "\nYou have #{8-@wrong_guesses} chances to be wrong, #{@player_name}. Please enter the letter you wanna try:"
            puts "\nGame Status: #{@gamespace}\n"
            guess = gets.gsub("\n","").downcase
        end
        letters_of_word = @word.gsub("\n","").downcase.split("")
        letters_of_word.each_with_index do |letter, index|
            if letter == guess
                @gamespace[index] = guess
                is_guess_wrong = false
            end
        end
        @wrong_guesses += 1 if is_guess_wrong
        @word_guessed_right = true unless @gamespace.include?('_') 
    end

    def play_game()
        make_empty_game_space()
        until @word_guessed_right || @wrong_guesses >= 8
            play_round()
        end
        @word_guessed_right ? puts("Congratulations, #{@player_name}! You found the word.") : puts("You lost, #{@player_name}.")
        puts "The word was #{@word}"
    end
end

def welcome()
    puts "Hi, would you like to play a hangman game?"
    answer = gets.gsub("\n", '')
    if answer == 'y' || answer == 'Y'
        puts "What's your name?"
        player_name = gets.gsub("\n",'')
        game = Game.new(player_name)
        game.play_game()
    else
        puts 'OK, bye.'
    end
end
welcome()