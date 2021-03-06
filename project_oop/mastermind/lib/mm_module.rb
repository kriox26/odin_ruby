module Mastermind
  # Define constants
  AI_NAMES = [ "HAL 9000", "T-1000", "R2-D2", "Optimus Prime", "Agent Smith", "Wall-E", "Skynet", "Sheldon Cooper"]
  AI_COMMENTS = { "HAL 9000" => { lose: "I know I've made some very poor decisions recently, but I can give you my complete assurance that my work will be back to normal." , win: "Thank you for a very enjoyable game." } , 
				  "T-1000" => { lose: "I'll be back", win: "Of course you lost, i'm a Terminator." },
				  "R2-D2" => { lose: "[chirps his objection]" , win: "[beeps] yeeeei"} ,
				  "Optimus Prime" => { lose: "I am Optimus Prime, and i send this message to any surviving autobots taking refuge among the start, i'v just lose with a human! " , win: "The greatest weakness of most humans is their hesitancy how they love them while they're alive, next time focues on the game instead..." } , 
				  "Agent Smith" => { lose: "I'll kill you" , win: "Human beings are a disease, a cancer of this planet. You're the living proof of it."} ,
				  "Wall-E" => { lose:"EEEEEEEEEEEEEVA" , win: "EEEEEEEEEEEEEVA" } , 
				  "Skynet" => { lose:"Humans are doomed" , win: "Humans are doomed" } , 
				  "Sheldon Cooper" => { lose: "When people are upset the cultural convention is to bring them a hot beverage, so bring me hot beverage..." , win: "BAZINGA!"}
  }

  COLORS = [:blue, :red, :white, :yellow, :green, :magenta]

  SPLIT = { vertical:  "\u2551", horizontal: "\u2550", cross:     "\u256c",
			nw_corner: "\u2554", ne_corner:  "\u2557", se_corner: "\u255d",
			sw_corner: "\u255a", n_divide:   "\u2566", s_divide:  "\u2569",
			e_divide:  "\u2563", w_divide:   "\u2560" }

  WELCOME_MESSAGE = <<-WELCOME
  Hello there! Mastermind is a two players game, in this game you will be playing against some famous AI!(like Skynet). You first decide 
  how many rounds you wanna play(it must be an even number). One player becomes the codemaker, the other the codebreaker. The codemaker 
  chooses a pattern of four code pegs. Duplicates are allowed, so the player could even choose four code pegs of the same color. The 
  chosen pattern is placed in the four holes covered by the shield, visible to the codemaker but not to the codebreaker. The codebreaker 
  may have a very hard time in finding out the code.
  The codebreaker tries to guess the pattern, in both order and color, within twelve turns. Each guess is made by placing a row of code 
  pegs on the decoding board. Once placed, the codemaker provides feedback by placing from zero to four key pegs in the small holes of 
  the row with the guess. A colored or black key peg is placed for each code peg from the guess which is correct in both color and position. 
  A white key peg indicates the existence of a correct color code peg placed in the wrong position.
  Now let's play Mastermind!!
  WELCOME

  def print_top_message(is_ai,name_of_ai)
	system "clear"
	puts "\t\t\t\tMastermind Game".colorize(:color=>:light_white,:background=>:light_magenta)
	puts
	if is_ai
	  puts "#{ name_of_ai } is playing!!"
	else
	  puts "You are playing!"
	  puts "Colors available: #{'       '.colorize(:background=>COLORS[0])}#{ '       '.colorize(:background=>COLORS[1])}#{ '       '.colorize(:background=>COLORS[2]) }#{ '       '.colorize(:background=>COLORS[3]) }#{ '       '.colorize(:background=>COLORS[4]) }#{ '       '.colorize(:background=>COLORS[5]) }"
	  puts "Choose with:        blue   red   white  yellow green magenta"
	end
	puts
	puts "\t\t       #{ 'Guess board'.colorize(:light_red) }\t    #{ 'Score board'.colorize(:light_red) }"
  end

  def generate_secret_code
	secret_code = [COLORS[rand(6)], COLORS[rand(6)], COLORS[rand(6)], COLORS[rand(6)]]
	return secret_code
  end

  def input_secret_code(name)
	print_top_message(false,'name')
	puts "Hey #{ name }. Enter secret code as a comma separated list(e.g: r,b,w,m): "
	loop do
	  secret_code = gets.chomp.split.join.split(',').map(&:to_sym)
	  return secret_code if check_code(secret_code,true)
	  puts 'That\'s not a valid code, try again, and remember the example: '.colorize(:red)
	end
  end

  def check_code(code, no_secret = false)
	# Checks if each color in guess is available in COLORS
	if code[0] == :kriox && !no_secret
	  return true
	else
	  if code == [] || code.length != 4 
		return false
	  end
	  parse_colors(code)
	  code.each do |element|
		return false if !(COLORS.include?(element))
	  end
	end
	return true
  end

  def parse_colors(code)
	code.map! do |color|
	  if color == :r
		:red
	  elsif color == :b
		:blue
	  elsif color == :w
		:white
	  elsif color == :g
		:green
	  elsif color == :y
		:yellow
	  elsif color == :m
		:magenta
	  else
		color
	  end
	end
  end

  def rate_guess(guess,secret_code,from_ai=false)
	i=0
	score = []
	guess_no_match = []
	secret_no_match = []
	guess.each_with_index do |color,index|
	  if secret_code[index] == color
		# Right color in right position
		score[i]=:black
		i+=1
	  else
		guess_no_match << color
		secret_no_match << secret_code[index]
	  end
	end
	guess_no_match.each do |color|
	  nodp = secret_no_match.index(color)
	  unless nodp.nil?
		secret_no_match.delete_at(nodp)
		score[i]=:white
		i+=1
	  end
	end
	if !from_ai
	  return score,secret_code==guess
	else
	  return score
	end
  end

  def message_until_enter(message)
	catch :press_enter do
	  loop do 
		puts message
		enter = gets
		throw :press_enter if enter == "\n"
	  end
	end
  end

  def print_secret_code(code)
	print "\t\t"
	print SPLIT[:nw_corner]
	4.times do |i|
	  5.times do
		print SPLIT[:horizontal]
	  end
	  if i == 3
		print SPLIT[:ne_corner]
	  else
		print SPLIT[:n_divide]
	  end
	end
	puts
	print "\t\t"
	print SPLIT[:vertical]
	4.times do |j|
	  print ' '
	  print '   '.colorize(:background => code[j])
	  print ' '
	  print SPLIT[:vertical]
	end
	puts
	print "\t\t"
	print SPLIT[:sw_corner]
	4.times do |k|
	  5.times do
		print SPLIT[:horizontal]
	  end
	  if k==3
		print SPLIT[:se_corner]
	  else
		print SPLIT[:s_divide]
	  end
	end
	puts
  end

  # only used when updating last rating of ai player
  def number_of_wb(array)
	whites = 0
	blacks = 0
	array.each do |element|
	  if element == :black
		blacks+=1
	  else
		if element == :white
		  whites+=1
		end
	  end
	end
	return [whites,blacks]
  end

  def go_crazy(secret_code)
	500.times do 
	  print "^*&^%$#$%^&*(*&^%$#$%^&*)" * rand(5)
	  print "WE ARE BEING HACKED!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
	  print "!@$#%^&%$#@@$#%" * rand(5)
	  puts
	  sleep 0.005
	end
	puts "You better be fast"
	print_secret_code(secret_code)
	sleep 0.8
  end

  def break_prog
    system "clear"
    puts "Someone hacked our security, nuclear explosion is inevitable!!!".colorize(:red)
	print "F".colorize(:red) * 30
	print "U".colorize(:red) * 90
	print "C".colorize(:red) * 4
	print "K".colorize(:red) * 10
	puts 
	bomb= <<-BOMB 

     _.-^^---....,,--
 _--                  --_
<                        >)
|                         |
 \._                   _./
    ```--. . , ; .--'''
          | |   |
       .-=||  | |=-.
       `-=#$%&%$#=-'
          | ;  :|
 _____.,-#%&$@%#&#~,._____ 
					
	BOMB
	puts bomb
	exit
  end

  # Methods that display top, center, middle and bottom lines

  def print_top_lines
	print "\t\t"
	print SPLIT[:nw_corner]
	4.times do |i|
	  5.times do
		print SPLIT[:horizontal]
	  end
	  if i == 3
		print SPLIT[:ne_corner]
	  else
		print SPLIT[:n_divide]
	  end
	end
	print '  '
	print SPLIT[:nw_corner]
	4.times do |i|
	  2.times do
		print SPLIT[:horizontal]
	  end
	  if i == 3
		print SPLIT[:ne_corner]
	  else
		print SPLIT[:n_divide]
	  end
	end
	puts
  end

  def print_center_boards
	12.times do |i|
	  print "\t\t"
	  print SPLIT[:vertical]
	  4.times do |j|
		print ' '
		print '   '.colorize(:background => @guess_board[i][j])
		print ' '
		print SPLIT[:vertical]
	  end
	  print '  '
	  print SPLIT[:vertical]
	  4.times do |k|
		print '  '.colorize(:background => @score_board[i][k])
		print SPLIT[:vertical]
	  end
	  puts
	  if i==11
		print_bottom_lines
	  else
		print_middle_lines
	  end
	  puts
	end
  end

  def print_middle_lines
	print "\t\t"
	print SPLIT[:w_divide]
	4.times do |i|
	  5.times do
		print SPLIT[:horizontal]
	  end
	  if i==3
		print SPLIT[:e_divide]
	  else
		print SPLIT[:cross]
	  end
	end
	print '  '
	print SPLIT[:w_divide]
	4.times do |i|
	  2.times do
		print SPLIT[:horizontal]
	  end
	  if i==3
		print SPLIT[:e_divide]
	  else
		print SPLIT[:cross]
	  end
	end
  end

  def print_bottom_lines
	print "\t\t"
	print SPLIT[:sw_corner]
	4.times do |k|
	  5.times do
		print SPLIT[:horizontal]
	  end
	  if k==3
		print SPLIT[:se_corner]
	  else
		print SPLIT[:s_divide]
	  end
	end
	print '  '
	print SPLIT[:sw_corner]
	4.times do |l|
	  2.times do
		print SPLIT[:horizontal]
	  end
	  if l==3
		print SPLIT[:se_corner]
	  else
		print SPLIT[:s_divide]
	  end
	end
  end
end
