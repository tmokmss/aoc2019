require "set"

if ARGV.length < 1
  input_path = "input/16.txt"
else
  input_path = "sample/16.txt"
end

puts "Load input from #{input_path}"

base = [0, 1, 0, -1]

input = File.read(input_path).strip()
input = input.chars.map(&:to_i)

p input

def coeff(pos, digit)
  # digit = 6, pos = 2 => -1
  digit = digit + 1
  all = 4 * pos
  rel = digit % all
  if rel < all / 4 # rel < pos
    0
  elsif rel < all / 2 # rel < pos * 2
    1
  elsif rel < all / 4 * 3 # rel < pos *3
    0
  else
    -1
  end
end

def next_phase(arr)
  n = arr.size
  (0...n).map do |i|
    (0...n).map do |j|
      arr[j] * coeff(i + 1, j)
    end.sum.abs % 10
  end
end

nexta = input
(0...100).each do |i|
  nexta = next_phase(nexta)
end

p nexta[0..7].join("")

dig = input[0...7].join.to_i
total = input.size * 10000
nn = total - dig

nexta = Array.new(nn, 0)
(0...nn).each do |i|
  nexta[nn - i - 1] = input[input.size - 1 - i % input.size]
end

def next_phase2(arr)
  n = arr.size
  nexta = Array.new(n, 0)
  nexta[n - 1] = arr[n - 1]
  (1...n).each do |i|
    nexta[n - 1 - i] = (arr[n - 1 - i] + nexta[n - i]) % 10
  end
  nexta
end

(0...100).each do |i|
  nexta = next_phase2(nexta)
end

p nexta[0..7].join("")
