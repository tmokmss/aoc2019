require "set"

if ARGV.length < 1
  input_path = "input/DAY.txt"
else
  input_path = "sample/DAY.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map do |line|
  match = /mem\[(.*)\] = (.*)/.match(line)
  [match[1], match[2]]
end

n = input.size
ans = 0

input.each_with_index do |line, i|
end

(0...n).each do |i|
  input[i]
end

puts(ans)
