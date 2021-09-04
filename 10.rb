require "set"

if ARGV.length < 1
  input_path = "input/10.txt"
else
  input_path = "sample/10.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map do |line|
  line.chars
end

height = parsed.size
width = parsed.first.size

asteroids = []
(0...height).each do |y|
  (0...width).each do |x|
    if parsed[y][x] == "#"
      asteroids.push([x, y])
    end
  end
end

angles = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
asteroids.each do |me|
  asteroids.each do |tar|
    next if me == tar
    angle = Math.atan2(tar[1] - me[1], tar[0] - me[0])
    if angle < -Math::PI / 2
      angle += 2 * Math::PI
    end
    angles[me][angle].push(tar)
  end
end

ans = angles.map { |k, v| [v.keys.size, k] }.max
p ans

origin = ans[1]
mm = angles[ans[1]]
newmm = mm.map do |k, v|
  newarr = v.sort_by { |t| -(t[0] - origin[0]) ** 2 - (t[1] - origin[1]) ** 2 }
  [k, newarr]
end.to_h

count = 0
th200 = []

newmm.keys.sort.each do |k|
  puts "#{k} #{newmm[k]}"
end

loop do
  newmm.keys.sort.each do |k|
    arr = newmm[k].pop
    if arr
      count += 1
    end
    if count == 200
      th200 = arr
      break
    end
  end

  if count == 200
    break
  end
end

p th200[0] * 100 + th200[1]
