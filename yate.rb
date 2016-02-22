require 'json'

# Yet another template language
# To run: $ ruby yate.rb template.yate data.json out.html

template = File.read(ARGV[0])
data = JSON.parse(File.read(ARGV[1]))
out_file = File.open(ARGV[2], 'w')

def apply(template, data)
  puts template
  puts data
  template
end

out_file << apply(template, data)

