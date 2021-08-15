require "set"

if ARGV.length < 1
  input_path = "input/6.txt"
else
  input_path = "sample/6.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map do |line|
  match = /(.*)\)(.*)/.match(line)
  [match[1], match[2]]
end

parent = Hash.new
child = Hash.new { |h, k| h[k] = [] }

parsed.each do |p, c|
  parent[c] = p
  child[p].push c
end

roots = child.keys.difference(parent.keys)
p roots # size should be 1
root = roots.first

def count_orbit(parent_orbit, children, child)
  if children.size == 0
    return parent_orbit
  end
  sum = parent_orbit
  children.each do |c|
    sum += count_orbit(parent_orbit + 1, child[c], child)
  end

  return sum
end

puts(count_orbit(0, child[root], child))

pathyou = []
pathsan = []
p parent

curr = "YOU"
loop do
  curr = parent[curr]
  pathyou.push(curr)
  break if curr == root
end

curr = "SAN"
loop do
  curr = parent[curr]
  pathsan.push(curr)
  break if curr == root
end

p pathsan
p pathyou
i = -1
loop do
  break if pathyou[i] != pathsan[i]
  i -= 1
end

p i
puts (pathyou.size + i + pathsan.size + i + 2)
