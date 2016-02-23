require 'json'

# Yet another template language
# To run: $ ruby yate.rb template.yate data.json out.html

template = File.new(ARGV[0])
data = JSON.parse(File.read(ARGV[1]))
out_file = File.open(ARGV[2], 'w')

# Read in a .yate file into an array of nodes
# Expects 'data' to support each_char
def parse(data)
  puts data
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

  return node_list
end

def apply(template, data)
  template.each do |node| puts node end
  # puts data
  template
end

out_file << apply(parse(template), data)

