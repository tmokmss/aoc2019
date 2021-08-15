require "set"

if ARGV.length < 1
  input_path = "input/5.txt"
else
  input_path = "sample/5.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).strip
parsed = input.split(",").map(&:to_i)

class Computer
  attr_reader :mem, :p, :input, :output

  def initialize(code)
    @mem = code.dup
    @p = 0
    @input = []
    @output = []
  end

  def add_input(c)
    @input.push(c)
  end

  def run()
    n = mem.size
    loop do
      break if p == n
      continue = step()
      break unless continue
    end
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
    case mem[p] % 100
    when 1
      mem[mem[p + 3]] = get_param(op, 1) + get_param(op, 2)
      @p += 4
    when 2
      mem[mem[p + 3]] = get_param(op, 1) * get_param(op, 2)
      @p += 4
    when 3
      mem[mem[p + 1]] = input.pop
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
      return false
    end

    true
  end
end

c = Computer.new(parsed)
c.add_input(5)
c.run
p c.output
p c.mem
