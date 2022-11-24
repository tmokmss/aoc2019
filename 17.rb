require "set"

if ARGV.length < 1
  input_path = "input/17.txt"
else
  input_path = "sample/17.txt"
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

c = Computer.new(parsed)
finished = c.run()

out = c.output
mapp = out.map(&:chr).join("").split("\n")
w = mapp[0].size
h = mapp.size

ans1 = 0
(1...h - 1).each do |i|
  (1...w - 1).each do |j|
    if mapp[i][j] == "#" && mapp[i - 1][j] == "#" && mapp[i + 1][j] == "#" && mapp[i][j - 1] == "#" && mapp[i][j + 1] == "#"
      ans1 += (i) * (j)
      p [i, j]
    end
  end
end

p ans1

c = Computer.new(parsed, nil, { 0 => 2 })
