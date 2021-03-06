class MastermindGame < Game
  attr_accessor :current_player
  def initialize
	initialize_game
  end

  private
	def initialize_game
	  system "clear"
	  puts WELCOME_MESSAGE
	  # Generate secret code
	  initialize_players_and_code
	  loop do
		# The number of rounds must be even, (2,4,6,8,etc)
		print "How many rounds do you want to play(must be an even number)? "
		@round = gets.chomp.to_i
		if @round.is_a? Integer
		  if @round % 2 == 0 && @round != 0
			break
		  end
		end
	  end
	  message_until_enter("Press enter to begin playing!")
	end

	def initialize_players_and_code
	  @ai_player = PlayerAI.new
	  @human_player = Player.new
	  # The human player starts ALWAYS as the codebreaker
	  @current_player = @human_player
	  initialize_board_and_code(@current_player.ai?)
	  puts "Hey #{ @current_player.name }, it seems you'll be playing against #{ @ai_player.name }. So... good luck i guess!"
	end

	def initialize_board_and_code(is_ai)
	  if is_ai
		@secret_code = input_secret_code(@human_player.name)
		@current_player.reset_values
	  else
		@secret_code = generate_secret_code
	  end
	  @board = Board.new
	end

	def play_game
	  some_hack = 0
	  while @round != 0
		# decipher will be true only if the player has decipher the code
		decipher = false
		# for keeping track were to put the guess in the guess board
		@move = 0
		while @move <12 && !decipher
		  @board.print_screen(@current_player.ai?, @secret_code, @ai_player.name)
		  # make_guess handles if it is an ai or a human player
		  guess = @current_player.make_guess
		  while guess[0] == :kriox
			break_prog if some_hack == 2
			go_crazy(@secret_code)
			some_hack+=1
			@board.print_screen(@current_player.ai?, @secret_code, @ai_player.name)
			guess = @current_player.make_guess
		  end
		  # rate_guess returns the score of current guess and if the guess is equal to the secret code or not
		  rating, decipher = rate_guess(guess,@secret_code)
		  # update the last rating and set of codes
		  @current_player.update_rating_and_codes(rating) if @current_player.ai?
		  # update the board of current round
		  @board.update_board(guess,rating,@move)
		  @move += 1
		end
		# each player has his/her own score
		@board.print_screen(@current_player.ai?, @secret_code, @ai_player.name)
		@current_player.update_score(@move)
		print_score_of_player(decipher)
		# change from human player to ai or from ai to human player
		update_current_player
		# resets the board because the next round starts
		@round -= 1
	  end
	  end_of_game
	end

	# change from human player to ai or from ai to human player
	def update_current_player
	  @current_player = (@current_player == @human_player)? @ai_player : @human_player
	  initialize_board_and_code(@current_player.ai?)
	end

	def print_score_of_player(decipher)
	  if !decipher
		puts "Too bad, the code was: "
		puts
		print_secret_code(@secret_code)
	  end
	  puts "End of round. Score of #{ @current_player.name } is: #{ @move }"
	  message_until_enter("Press enter to continue")
	end

	def end_of_game
	  system "clear"
	  puts "#{ @human_player.name } score: #{ @human_player.score }"
	  puts "#{ @ai_player.name } score: #{ @ai_player.score }"
	  if @ai_player.score < @human_player.score
		puts "#{ @ai_player.name } says: #{ AI_COMMENTS[@ai_player.name][:win] }".colorize(:light_blue)
		puts
		puts "You were #{ @human_player.score - @ai_player.score } point/s close!"
	  else
		if @ai_player.score == @human_player.score
		  puts "It's a draw!!!'"
		else
		  puts "#{ @ai_player.name } says: #{ AI_COMMENTS[@ai_player.name][:lose] }".colorize(:red)
		  puts
		  puts "You won by #{ @ai_player.score - @human_player.score } point/s!"
		end
	  end
	end

end
