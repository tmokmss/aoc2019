require "set"

if ARGV.length < 1
  input_path = "input/12.txt"
else
  input_path = "sample/12.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map do |line|
  match = /x=(.*?), y=(.*?), z=(.*?)>/.match(line)
  [match[1], match[2], match[3]].map(&:to_i)
end

class Body1D
  attr_reader :val, :diff

  def initialize(init)
    @val = init
    @diff = 0
  end

  def calc_diff(other)
    @diff += vel_diff(@val, other.val)
  end

  def apply
    @val += @diff
  end

  def to_s
    "#{@val}##{@diff}"
  end

  private def vel_diff(me, opp)
    return 0 if me == opp
    return -1 if me - opp > 0
    return 1
  end
end

class Body
  attr_accessor :dim

  def initialize(dim)
    @dim = dim.map { |p| Body1D.new(p) }
  end

  def calc_velocity(other)
    (0..2).each do |i|
      dim[i].calc_diff(other.dim[i])
    end
  end

  def apply_velocity
    dim.each(&:apply)
  end

  def potential_energy
    @dim.map { |p| p.val.abs }.sum * @dim.map { |p| p.diff.abs }.sum
  end
end

bodies = parsed.map { |p| Body.new(p) }
(0...1000).each do |i|
  bodies.each do |bm|
    bodies.each do |bt|
      bm.calc_velocity(bt)
    end
  end
  bodies.each do |b|
    b.apply_velocity
  end
end

p bodies.map(&:potential_energy).sum

xs = parsed.map { |p| Body1D.new(p[0]) }
ys = parsed.map { |p| Body1D.new(p[1]) }
zs = parsed.map { |p| Body1D.new(p[2]) }

def find_repeat(xs)
  initx = xs.map { |x| x.to_s }.join("#")
  countx = 0
  loop do
    xs.each do |bm|
      xs.each do |bt|
        bm.calc_diff(bt)
      end
    end
    xs.each do |b|
      b.apply
    end
    countx += 1
    break if xs.map { |x| x.to_s }.join("#") == initx
  end
  countx
end

countx = find_repeat(xs)
county = find_repeat(ys)
countz = find_repeat(zs)
p countx, county, countz
p countx.lcm(county).lcm(countz)
