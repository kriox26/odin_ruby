# Copy of ruby building blocks, source code stays the same, i copied it to build some rspec
# Matias Pan - https://github.com/kriox26/
#
# Implement this two methods for checking if a character is lower or upper case
  def is_upper?(c)
    return c == c.capitalize
  end
  # Actually i only use one, but i implement both just in case
  def is_lower?(c)
    return c != c.capitalize
  end
# Check if current char is a letter
  def letter?(look_a_head)
    look_a_head =~ /[A-Za-z]/
  end
# parse_letter returns the letter shifted key places
  def parse_letter(from_where, letter, key)
    # Check if you go from Z to A or z to a
    return (letter.ord + key > from_where)?((letter.ord + key - 26).chr):((letter.ord + key).chr)
  end

def caesar_cipher(string,key)
  if key<0 || string.empty?
  	return nil
  end
  key = key.to_i
  # this only matters when key > 26, for example, key = 27 --> key = 27 % 26 = 1
  key = key % 26
  string.length().times do |i|
  	# If the char is not a letter, we leave it the way it is, it's how caesar works
  	if letter?(string[i])
  	  if is_upper?(string[i])
    		# call to parse_letter with upcase, we do this to mantain their case
    		string[i] = parse_letter(90, string[i], key)
  	  else
    		# same thing but with lower case
    		string[i] = parse_letter(122, string[i], key)
  	  end
  	end
  end
  return string
end
