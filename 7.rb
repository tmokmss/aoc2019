require "set"

if ARGV.length < 1
  input_path = "input/7.txt"
else
  input_path = "sample/7.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).strip
parsed = input.split(",").map(&:to_i)

class Computer
  attr_reader :mem, :p, :input, :output

  def initialize(code, input = nil)
    @mem = code.dup
    @p = 0
    @input = input || []
    @output = []
  end

  def add_input(c)
    @input.push(c)
  end

  def run(til = nil)
    n = mem.size
    exited = true
    loop do
      break if p == n
      lastop = step()
      break if lastop == 99
      break exited = false if lastop == til
    end
    exited
  end

  # get [num]th param with the right mode
  private def get_param(op, num)
    op = op / 100
    mode = (op / 10 ** (num - 1)) % 10
    if mode == 0
      mem[mem[p + num]]
    else mode == 1
      mem[p + num]     end
  end

  private def step()
    op = mem[p]
    operator = mem[p] % 100
    case operator
    when 1
      mem[mem[p + 3]] = get_param(op, 1) + get_param(op, 2)
      @p += 4
    when 2
      mem[mem[p + 3]] = get_param(op, 1) * get_param(op, 2)
      @p += 4
    when 3
      mem[mem[p + 1]] = input.shift
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
      mem[mem[p + 3]] = get_param(op, 1) < get_param(op, 2) ? 1 : 0
      @p += 4
    when 8
      mem[mem[p + 3]] = get_param(op, 1) == get_param(op, 2) ? 1 : 0
      @p += 4
    when 99
    end

    operator
  end
end

phases = [0, 1, 2, 3, 4]
ans = phases.permutation.map do |phase|
  input = 0
  phase.each do |i|
    c = Computer.new(parsed)
    c.add_input(i)
    c.add_input(input)
    c.run(4)
    input = c.output[0]
  end
  input
end.max

puts ans

phases = [5, 6, 7, 8, 9]
ans = phases.permutation.map do |phase|
  input = 0
  computers = {}
  loop do
    exited = false
    phase.each do |i|
      c = computers[i] ||= Computer.new(parsed, [i])
      c.add_input(input)
      exited = c.run(4)
      input = c.output[-1]
    end
    break if exited
  end
  input
end.max

puts ans
