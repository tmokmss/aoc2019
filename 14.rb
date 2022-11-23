require "set"

if ARGV.length < 1
  input_path = "input/14.txt"
else
  input_path = "sample/14.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map do |line|
  match = /(.*?) => (\d+) ([A-Z]+)/.match(line)
  [match[3], [match[2].to_i, match[1].split(",").map { |s| a = s.split; [a[1], a[0].to_i] }.to_h]]
end.to_h

p parsed

pool = Hash.new(0)

def get_ore(ingredient, num, pool, parsed)
  return num if ingredient == "ORE"

  pooled = pool[ingredient]
  produce = num
  if pooled > 0
    produce -= [pooled, num].min
    pool[ingredient] -= [pooled, num].min
  end
  return 0 if produce == 0

  me = parsed[ingredient]
  count = (produce * 1.0 / me[0]).ceil

  ans = 0
  me[1].map do |ing, n|
    ans += get_ore(ing, n * count, pool, parsed)
  end

  pool[ingredient] += me[0] * count - produce
  return ans
end

p get_ore("FUEL", 1, pool, parsed)

target = 1000000000000
n1 = 100
n2 = 5586022
nextn = (n1 + n2) / 2
prevn = n1
loop do
  pool = Hash.new(0)
  prevn = nextn
  a = get_ore("FUEL", nextn, pool, parsed)
  p [a, nextn]
  if a > target
    n2 = nextn
    nextn = (n1 + n2) / 2
  else
    n1 = nextn
    nextn = (n1 + n2) / 2
  end
  break if nextn == prevn
end

p nextn
