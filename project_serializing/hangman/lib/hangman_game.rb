class Hangman
  attr_accessor :player_name, :right_chars, :wrong_chars, :secret_word, :figure
  def initialize
	menu
  end

  private
	def display_menu
	  puts "Choose an option:"
	  puts
	  print "\t1.".colorize(:color => :light_blue)
	  puts " Play new game"
	  print "\t2.".colorize(:color => :light_blue)
	  puts " Load a saved game"
	  print "\t3.".colorize(:color => :light_blue)
	  puts " Remove saved games"
	  print "\t4.".colorize(:color => :light_blue)
	  puts " Exit"
	end
	def menu
	  # Should display the menu with: play new game, load game and quit, then ask you that you wanna do
	  system("clear")
	  puts MENU_MESSAGE
	  loop do
		display_menu
		puts
		print "Choose with 1,2,3 or 4: "
		choice = gets.chomp
		case choice
		when "1"
		  play_game
		  break
		when "2"
		  load_game
		  break
		when "3"
		  remove_game
		  break
		when "4"
		  quit_game
		  break
		else
		  puts "Invalid answer, try again.".colorize(:red)
		end
	  end
	end

	def play_game
	  # ask for players name . Generate secret word
	  # play while the player doesn't guess the word or he/she still has lives
	  print "Player name: "
	  @player_name = gets.chomp
	  @figure      = HangmanDisplay.new
	  @loaded_game = ''
	  generate_secret_word
	  play
	end

	def play
	  while @wrong_chars.length < 14
		@figure.display_game_board(@right_chars,@wrong_chars)
		break if make_and_rate
	  end
	  @right_chars = @secret_word
	  @figure.display_game_board(@right_chars,@wrong_chars)
	  if @wrong_chars.length == 14
		puts "Sorry #{ @player_name } you lost!"
	  else
		puts "Great job #{@player_name}!"
		if @loaded_game != ''
		  delete(@loaded_game)
		end
	  end
	  exit
	end

	def generate_secret_word
	  # take a sample from the array with each word of the dictionary
	  loop do
		@secret_word = File.readlines("dictionary.txt").sample.split(//)
		break if @secret_word.length > 4 && @secret_word.length < 15
	  end
	  @secret_word.delete_at(@secret_word.length-1)
	  @right_chars = Array.new(@secret_word.length, "_")
	  update_corrects(@secret_word[0])
	  @wrong_chars = []
	  return @secret_word
	end

	def make_and_rate
	  # the user can input a word or a char, if input is larger that one it's a word, else it's a char
	  puts INPUT_MESSAGE
	  guess = ''
	  loop do
		print "Your choice: "
		guess = gets.chomp
		break if check_input(guess)
	  end
	  if guess.length > 1
		if guess.downcase != 'save'
		  if guess.downcase != 'quit'
			return check_word(guess)
		  else
			quit_game
		  end
		else
		  save_game
		  return false
		end
	  else
		return check_char(guess)
	  end
	end

	def check_word(word)
	  if !(word.split(//) == @secret_word)
		@wrong_chars << word
		return false
	  else
		return true
	  end
	end

	def check_char(char)
	  if @secret_word.include?(char)
		if !@right_chars.include?(char)
		  update_corrects(char)
		else
		  puts "You already choose that character, choose another!"
		  sleep 1
		end
	  else
		if !@wrong_chars.include?(char)
		  update_wrongs(char)
		else
		  puts "You already choose that character, choose another!"
		  sleep 1
		end
	  end
	  @secret_word == @right_chars
	end

	def update_corrects(char)
	  index = []
	  @secret_word.each_with_index do |car,i|
		index << i if car == char
	  end
	  index.each do |i|
		@right_chars[i] = char
	  end
	end

	def update_wrongs(char)
	  @wrong_chars << char
	end

	def save_game
	  name 	  = get_name_to_save
	  content   = [self]
	  game_info = YAML::dump(content)
	  File.open(name, "w+").puts(game_info)
	  puts "Game has been saved as #{name}!"
	  sleep 2
	end

	def load_data(name)
	  if File.exists?(name)
		game_info        = File.read(name)
		content          = YAML::load(game_info)
		self.player_name = content[0].player_name
		self.wrong_chars = content[0].wrong_chars
		self.right_chars = content[0].right_chars
		self.secret_word = content[0].secret_word
		self.figure 	   = content[0].figure
		@loaded_game = name
		puts "Game load, let's play!"
		play
	  else
		puts "Game doesn't exist, try again!".colorize(:red)
	  end
	end
	def load_game
	  games_available = get_games_available
	  if games_available != []
		if games_available.length > 1
		  display(games_available) { |elem| print "#{elem}, "}
		  puts
		  loop do
			name = name_message("Name of the game to load: ")
			load_data(name)
		  end
		else
		  load_data(games_available[0] + ".yml")
		end
	  else
		puts "There are no games to load! Returning to the menu..."
		sleep 1.5
		menu
	  end
	end

	def remove_game
	  games = get_games_available
	  if games != []
		display(games) { |elem| print "#{elem}, "}
		puts
		removed = 0
		total = games.length
		loop do
		  name = name_message("Name of the game to remove: ")
		  if File.exists?(name)
			delete(name)
			puts "Deleted!"
			removed += 1
		  else
			puts "That file doesn't exist!".colorize(:red)
		  end
		  if removed == total
			puts "No more games to remove, going back to the menu..."
			sleep 1.5
			break
		  end
		  print "To continue removing, press enter, to go back to the menu type n and press enter: "
		  choice = gets.chomp
		  break if choice.downcase == 'n'
		end
	  else
		puts "No games to remove! Returning to the menu..."
		sleep 1.5
	  end
	  menu
	end

end
