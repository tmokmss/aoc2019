require "set"

if ARGV.length < 1
  input_path = "input/3.txt"
else
  input_path = "sample/3.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
l1, l2 = input.map { |l| l.split(",").map { |t| [t[0], t[1..-1].to_i] } }

def direction(c)
  case c
  when "R"
    [1, 0]
  when "L"
    [-1, 0]
  when "U"
    [0, 1]
  when "D"
    [0, -1]
  end
end

seen = Hash.new
intersect = {}
curr = [0, 0]
step = 0
l1.each do |ll|
  dir, val = ll
  dvec = direction(dir)
  val.times do
    step += 1
    curr[0] += dvec[0]
    curr[1] += dvec[1]
    seen[curr.dup] ||= step
  end
end

curr = [0, 0]
step = 0
l2.each do |ll|
  dir, val = ll
  dvec = direction(dir)
  val.times do
    step += 1
    curr[0] += dvec[0]
    curr[1] += dvec[1]
    if seen.has_key?(curr)
      intersect[curr.dup] = [seen[curr], step]
    end
  end
end

p intersect
puts(intersect.map { |k, v| k[0].abs + k[1].abs }.min)
puts(intersect.map { |k, v| v[0].abs + v[1].abs }.min)
