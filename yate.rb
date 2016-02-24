require 'json'

# Yet another template engine
# To run: $ ruby yate.rb template.yate data.json out.html

template = File.read(ARGV[0]).split("")
data = JSON.parse(File.read(ARGV[1]))
out_file = File.open(ARGV[2], 'w')

# Read in a .yate file into an array of nodes
# Expects 'data' to support each_char
def parse(data, end_tag)
  state = :outside
  # Possible states: :outside, :in_tag, :in_open, :in_close
  
  node_list = []
  current_node = {text: '', type: :normal}
  # I'm not 100% sure what the smartest way to do this is.
  # There are a few possibilities I looked at:
  # * Mutating the string on each iteration, removing the first
  # char (less readable syntax, seems wasteful to create so many
  # strings)
  # * Keeping a counter going (and passing the counter back and
  # fourth through recursive calls)
  #
  # I settled for the most readable answer I could come up with,
  # which is just splitting it and mutitating an array (it should
  # be more obvious what's going on in that case, and we use the
  # array to maintain the state of where we are in the string.

  # It would probably be wise to profile all three options later,
  # and pick the fastest (I suspect it's the 'counter' method)
  loop do
    next_char = data.shift
    break if next_char == nil
    if state == :in_open
      if next_char == '*'
        node_list.push(current_node)
        current_node = {text: '', type: :tag}
        state = :in_tag
      else
        current_node[:text] += '<' + next_char
        state = :outside
      end
    elsif state == :in_close
      if next_char == '>'
        current_node[:args] = current_node[:text].split(' ')

        state = :outside
        if current_node[:args][0] == end_tag
          break
        end

        node_list.push(current_node)
        if current_node[:args][0] == "EACH"
          current_node[:children] = parse(data, "ENDEACH")
        end
        current_node = {text: '', type: :normal}
      else
        current_node[:text] += '*' + next_char
        state = :in_tag
      end
    elsif state == :in_tag
      if next_char == '*'
        state = :in_close
      else
        current_node[:text] += next_char
      end
    elsif state == :outside
      if next_char == '<'
        state = :in_open
      else
        current_node[:text] += next_char
      end
    else
      puts "bad state"
      puts state
    end
  end
  
  if state == :in_tag
    raise "Error: Encounterer EOF inside tag"
  else
    node_list.push(current_node)
  end

  return node_list
end

# Get a piece of data by key from the scope chain.

# We're doing enough with the scope chain that it almost
# makes sense to use a class.
# almost.
def get_data(dot_seperated_keys, scope_chain)
  keys = dot_seperated_keys.split(".")

  value = nil
  scope_chain.each do | scope |
    if scope.has_key?(keys[0])
      value = scope[keys[0]]
      keys.shift
      # we handle the first key differently
      # because we need to get the value from the
      # scope before we can work on it.
      keys.each do | key |
        if value.has_key?(key)
          value = value[key]
        else
          value = nil
          break
        end
      end
      break
    end
  end
  if value == nil
    # puts "Could not find key #{dot_seperated_keys} in any scope"
    # Should this crash the script?
  end
  return value
end

# Bind data from the scope chain to a template.
#
# Expects the template in a list of nodes, 
# expects the scope chain as a list of hashes.
def apply(template, scope_chain)
  processed = ""
  template.each do | node|
    if node[:type] == :normal
      processed += node[:text]
    elsif node[:type] == :tag
      if node[:args][0] == 'EACH'
        get_data(node[:args][1], scope_chain).each do | iterator |
          new_scope_frame = {}
          new_scope_frame[node[:args][2]] = iterator
          scope_chain.push new_scope_frame
          processed += apply(node[:children], scope_chain)
          scope_chain.pop
        end
      elsif node[:args].length == 1
        value = get_data(node[:args][0], scope_chain)
        if value != nil
          processed += value
        end
      end
    end
    
  end
  
  return processed
end

def process_template(template, data)
  return apply(parse(template, nil), [data])
end

out_file << process_template(template, data)

