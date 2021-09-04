require "set"

if ARGV.length < 1
  input_path = "input/11.txt"
else
  input_path = "sample/11.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).strip
parsed = input.split(",").map(&:to_i)

class Computer
  attr_reader :mem, :p, :input, :output, :rbase

  def initialize(code, input = nil)
    @mem = Hash.new { |h, k| h[k] = 0 }
    code.each_with_index { |e, i| @mem[i] = e }
    @p = 0
    @input = input || []
    @output = []
    @rbase = 0
  end

  def add_input(c)
    @input.push(c)
  end

  def run(til = nil)
    exited = true
    loop do
      lastop = step()
      break if lastop == 99
      break exited = false if lastop == til
    end
    exited
  end

  # get [num]th param with the right mode
  private def get_param(op, num)
    mem[get_param_pos(op, num)]
  end

  private def put_param(op, num, val)
    mem[get_param_pos(op, num)] = val
  end

  private def get_param_pos(op, num)
    op = op / 100
    mode = (op / 10 ** (num - 1)) % 10
    case mode
    when 0
      mem[p + num]
    when 1
      p + num
    when 2
      rbase + mem[p + num]
    end
  end

  private def step()
    op = mem[p]
    operator = mem[p] % 100
    case operator
    when 1
      put_param(op, 3, get_param(op, 1) + get_param(op, 2))
      @p += 4
    when 2
      put_param(op, 3, get_param(op, 1) * get_param(op, 2))
      @p += 4
    when 3
      put_param(op, 1, input.shift)
      @p += 2
    when 4
      output.push(get_param(op, 1))
      @p += 2
    when 5
      if get_param(op, 1) != 0
        @p = get_param(op, 2)
      else
        @p += 3
      end
    when 6
      if get_param(op, 1) == 0
        @p = get_param(op, 2)
      else
        @p += 3
      end
    when 7
      put_param(op, 3, get_param(op, 1) < get_param(op, 2) ? 1 : 0)
      @p += 4
    when 8
      put_param(op, 3, get_param(op, 1) == get_param(op, 2) ? 1 : 0)
      @p += 4
    when 9
      @rbase += get_param(op, 1)
      @p += 2
    when 99
    end

    operator
  end
end

INPUT_BLACK = 0
INPUT_WHITE = 1

def dir(cur, rot)
  t = Math::PI * 2 * rot / 360
  [cur[0] * Math.cos(t) - cur[1] * Math.sin(t), cur[0] * Math.sin(t) + cur[1] * Math.cos(t)].map(&:round)
end

panels = Hash.new { |h, k| h[k] = INPUT_BLACK }
point = [0, 0]
direction = [0, 1]
panels[[0, 0]] = INPUT_WHITE

robot = Computer.new(parsed)
loop do
  robot.add_input(panels[point])
  finished = robot.run(4)
  finished ||= robot.run(4)
  rot = robot.output.pop == 0 ? 90 : -90
  color = robot.output.pop
  panels[[point[0], point[1]]] = color
  direction = dir(direction, rot)
  point = [point[0] + direction[0], point[1] + direction[1]]
  break if finished
end

p panels.keys.count

x0 = panels.keys.map { |p| p[0] }.min
x1 = panels.keys.map { |p| p[0] }.max
y0 = panels.keys.map { |p| p[1] }.min
y1 = panels.keys.map { |p| p[1] }.max
p [x0, y0, x1, y1]

blk = "_"
wht = "#"
paint = Array.new(y1 - y0 + 1) { Array.new(x1 - x0 + 1) { blk } }
panels.each do |k, v|
  paint[y1 - (k[1] - y0) - 1][(k[0] - x0)] = v == 1 ? wht : blk
end
paint.each do |line|
  p line.join("")
end
