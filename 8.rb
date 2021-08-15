require "set"

if ARGV.length < 1
  input_path = "input/8.txt"
else
  input_path = "sample/8.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip).first

WIDTH = 25
HEIGHT = 6

# WIDTH = 2
# HEIGHT = 2

layers = input.chars.each_slice(WIDTH * HEIGHT).map do |layer|
  layer.each_slice(WIDTH).map do |row|
    row.map(&:to_i)
  end
end

puts "#{layers.size} layers"

def count_num(layer, num)
  layer.map { |row| row.count(num) }.sum
end

_, idx = layers.map { |layer| count_num(layer, 0) }.each_with_index.max

puts count_num(layers[idx], 1) * count_num(layers[idx], 2)

image = Array.new(HEIGHT) { Array.new(WIDTH) { " " } }

(0...HEIGHT).each do |i|
  (0...WIDTH).each do |j|
    (0...layers.size).each do |k|
      if layers[k][i][j] != 2
        image[i][j] = layers[k][i][j] == 0 ? " " : "o"
        break
      end
    end
  end
  puts image[i].join("")
end
