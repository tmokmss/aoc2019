require "set"

if ARGV.length < 1
  input_path = "input/15.txt"
else
  input_path = "sample/15.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).strip
parsed = input.split(",").map(&:to_i)

class Computer
  attr_reader :mem, :p, :input, :output, :rbase

  def initialize(code, input = nil, meminit = {})
    @mem = Hash.new { |h, k| h[k] = 0 }
    code.each_with_index { |e, i| @mem[i] = e }
    meminit.each { |k, v| @mem[k] = v }
    @p = 0
    @input = input || []
    @output = []
    @rbase = 0
  end

  def add_input(c)
    @input.push(c)
  end

  def clear_output
    @output = []
  end

  def run(til = nil, stop = nil)
    exited = false
    first = true  # won't stop even if op == stop when it is the first step
    loop do
      lastop = step(first ? nil : stop)
      break if lastop == nil
      break exited = true if lastop == 99
      break if lastop == til
      first = false
    end
    exited
  end

  def to_s
    # :mem, :p, :input, :output, :rbase
    "p: #{p}, around p: #{(p - 5..p + 5).map { |pp| mem[pp] }}, "
  end

  # get [num]th param with a specified mode
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

  private def step(stop)
    op = mem[p]
    operator = mem[p] % 100
    return nil if operator == stop

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
      begin
        put_param(op, 3, get_param(op, 1) < get_param(op, 2) ? 1 : 0)
      rescue => e
        puts "#{mem}"
        puts "#{[get_param(op, 1), get_param(op, 2), op]}"
        raise e
      end
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

class Map
  attr_reader :dots, :pos

  def initialize()
    @dots = Hash.new { |h, k| h[k] = {} }
    @pos = [0, 0]
    @dots[0][0] = "D"
  end

  def move(key, res)
    dir = key_to_dir(key)
    if res == 0
      @dots[@pos[1] + dir[1]][@pos[0] + dir[0]] = "#"
    elsif res == 1
      @dots[@pos[1]][@pos[0]] = "." if @dots[@pos[1]][@pos[0]] != "X"
      @dots[@pos[1] + dir[1]][@pos[0] + dir[0]] = "D"
      @pos = [@pos[0] + dir[0], @pos[1] + dir[1]]
    elsif res == 2
      @dots[@pos[1]][@pos[0]] = "."
      @dots[@pos[1] + dir[1]][@pos[0] + dir[0]] = "X"
      @ox = [@pos[0] + dir[0], @pos[1] + dir[1]]
      @pos = [@pos[0] + dir[0], @pos[1] + dir[1]]
    else
      raise "invalid res #{res}"
    end
  end

  def remaining()
    rem = []
    rem.push(4) if @dots[@pos[1]][@pos[0] - 1].nil?
    rem.push(3) if @dots[@pos[1]][@pos[0] + 1].nil?
    rem.push(2) if @dots[@pos[1] + 1][@pos[0]].nil?
    rem.push(1) if @dots[@pos[1] - 1][@pos[0]].nil?
    rem
  end

  def key_to_dir(key)
    case key
    when 1
      [0, -1]
    when 2
      [0, 1]
    when 3
      [1, 0]
    when 4
      [-1, 0]
    end
  end

  def print
    # p @dots
    xmin = @dots.values.map { |v| v.keys.min }.compact.min
    xmax = @dots.values.map { |v| v.keys.max }.compact.max
    ymin = @dots.keys.min
    ymax = @dots.keys.max
    h = ymax - ymin + 1
    w = xmax - xmin + 1
    disp = Array.new(h) { Array.new(w) { " " } }
    @dots.each do |yy, xs|
      xs.each do |xx, c|
        disp[yy - ymin][xx - xmin] = c
      end
    end
    disp.each do |line|
      puts line.join("")
    end
  end

  def next_step()
    @dots.each do |yy, xs|
      xs.each do |xx, c|
        @dots[yy][xx] = "." if c == "D"
        next unless c == "."
        if @dots[yy][xx - 1] == "X" || @dots[yy][xx + 1] == "X" || @dots[yy - 1][xx] == "X" || @dots[yy + 1][xx] == "X"
          @dots[yy][xx] = "x"
        end
      end
    end
    @dots.each do |yy, xs|
      xs.each do |xx, c|
        @dots[yy][xx] = "X" if c == "x"
      end
    end
    @dots.values.all? { |v| !v.values.include?(".") }
  end
end

def rev(dir)
  case dir
  when 1
    2
  when 2
    1
  when 3
    4
  when 4
    3
  end
end

mapp = Map.new()
c = Computer.new(parsed)
stack = [[]]
curr = []
ans1 = 0
loop do
  begin
    dirs = mapp.remaining
    if dirs.empty?
      target = stack.pop
      break if target.nil?
      move = curr[target.size...curr.size].reverse.map { |a| rev(a) }
      move.each do |input|
        # go back to the previous location
        c.add_input(input)
        finished = c.run(4)
        out = c.output
        c.clear_output
        res = out[0]
        mapp.move(input, res)
      end

      curr = target
      next
    end
    input = dirs[0]
    c.add_input(input)

    finished = c.run(4)
    out = c.output
    c.clear_output
    res = out[0]
    mapp.move(input, res)
    if res == 2
      curr.push(input)
      puts "found the target"
      ans1 = curr.length
    elsif res == 1
      stack.push(curr.clone) if dirs.size > 1 # come back later
      curr.push(input) # record direction history
    end
    break if finished
  rescue => e
    puts c.to_s
    raise e
  end
end

mapp.print
p ans1

ans2 = 0
loop do
  ans2 += 1
  finished = mapp.next_step()
  break if finished
end

p ans2
