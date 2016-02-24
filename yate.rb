require 'json'

# Yet another template engine
# To run: $ ruby yate.rb template.yate data.json out.html

template = File.new(ARGV[0])
data = JSON.parse(File.read(ARGV[1]))
out_file = File.open(ARGV[2], 'w')

# Read in a .yate file into an array of nodes
# Expects 'data' to support each_char
def parse(data)
  state = :outside
  # Possible states: :outside, :in_tag, :in_open, :in_close
  
  node_list = []
  current_node = {text: '', type: :normal}

  data.each_char do | next_char |
    # puts next_char
    # puts state
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
        node_list.push(current_node)
        current_node = {text: '', type: :normal}
        state = :outside
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
def get_data(key, scope_chain)
  value = nil
  scope_chain.each do | scope |
    if scope.has_key?(key)
      value = scope[key]
      break
    end
  end
  if value == nil
    puts "Could not find value #{value} in any scope"
    # Should this crash the script?
  end
  return value
end

# Bind data from the scope chain to a template.
#
# Expects the template in a list of nodes, 
# expects the scope chain as a list of hashes.
def apply(template, scope_chain)
  template.each do |i| puts i end
  processed = ""
  loop do # Would a `while true` be more idiomatic?
    node = template.shift
    break if node == nil
    
    if node[:type] == :normal
      processed += node[:text]
    elsif node[:type] == :tag
      # TODO: Process tags here
    end
    
  end
  
  return processed
end

out_file << apply(parse(template), [data])

