require "set"

if ARGV.length < 1
  input_path = "input/13.txt"
else
  input_path = "sample/13.txt"
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

class Disassembler
  attr_reader :code, :dump

  def initialize(code)
    @code = code
    @dump = {}
  end

  def run
    add_dump(0)
    (0...code.size).each do |i|
      next if @dump[i] == ""
      puts line(@dump[i], code[i], i)
    end
  end

  private def line(content, op, p)
    "#{p} #{content} (#{op})"
  end

  private def get_param(op, num, p)
    code[get_param_pos(op, num, p)]
  end

  private def get_param_pos(op, num, p)
    op = op / 100
    mode = (op / 10 ** (num - 1)) % 10
    case mode
    when 0
      code[p + num]
    when 1
      p + num
    when 2
      0 + code[p + num]
    end
  end

  private def add_dump(p)
    return if @dump.has_key?(p)
    return if p >= code.size

    op = code[p]
    operator = code[p] % 100
    ret = ""
    pinc = 0

    case operator
    when 1
      @dump[p] = "#{code[p + 3]} <- param #{code[p + 1]} + param #{code[p + 2]}"
      pinc = 4
    when 2
      @dump[p] = "#{code[p + 3]} <- param #{code[p + 1]} * param #{code[p + 2]}"
      pinc = 4
    when 3
      @dump[p] = "#{code[p + 1]} <- input"
      pinc = 2
    when 4
      @dump[p] = "#{code[p + 1]} -> output"
      pinc = 2
    when 5
      @dump[p] = "jump to #{code[p + 2]} if #{code[p + 1]} != 0"
      add_dump(get_param(op, 2, p))
      pinc = 3
    when 6
      @dump[p] = "jump to #{code[p + 2]} if #{code[p + 1]} == 0"
      add_dump(get_param(op, 2, p))
      pinc = 3
    when 7
      @dump[p] = "#{code[p + 3]} <- #{code[p + 1]} < #{code[p + 2]} ? 1 : 0"
      pinc = 4
    when 8
      @dump[p] = "#{code[p + 3]} <- #{code[p + 1]} == #{code[p + 2]} ? 1 : 0"
      pinc = 4
    when 9
      @dump[p] = "rbase += #{code[p + 1]}"
      pinc = 2
    when 99
      @dump[p] = "exit"
      pinc = 1
      return
    else
      return
    end
    (1...pinc).each { |i| @dump[p + i] = "" }

    add_dump(p + pinc)
  end
end

c = Computer.new(parsed)
c.run

p c.output.each_slice(3).count { |t| t[2] == 2 }
p c.output.each_slice(3).count { |t| t[2] == 3 }

x0 = c.output.each_slice(3).map { |t| t[0] }.min
x1 = c.output.each_slice(3).map { |t| t[0] }.max
y0 = c.output.each_slice(3).map { |t| t[1] }.min
y1 = c.output.each_slice(3).map { |t| t[1] }.max
p [x0, x1, y0, y1]

class Display
  attr_reader :dots, :score

  def initialize(w, h)
    @dots = Array.new(h) { Array.new(w) { " " } }
  end

  def input(slices)
    slices.each_slice(3) do |slice|
      if slice[0] == -1 && slice[1] == 0
        @score = slice[2]
        next
      end
      dots[slice[1]][slice[0]] = case slice[2]
        when 0
          " "
        when 1
          "|"
        when 2
          "M"
        when 3
          "-"
        when 4
          "O"
        end
    end
  end

  def print
    dots.each do |line|
      puts line.join("")
    end
    puts "score: #{score}"
  end
end

display = Display.new(x1 - x0 + 1, y1 - y0 + 1)

# dis = Disassembler.new(parsed)
# dis.run

c = Computer.new(parsed, [], { 0 => 2 })
padx = 0
loop do
  begin
    finished = c.run(nil, 3)
    out = c.output
    c.clear_output
    display.input(out)
    display.print
    break if finished

    p out
    pad = out.each_slice(3).find { |t| t[2] == 3 }
    sph = out.each_slice(3).find { |t| t[2] == 4 }[0]
    padx = pad[0] unless pad.nil?

    p [padx, sph]
    key = if padx == sph
        0
      elsif padx > sph
        -1
      else 1       end
    c.add_input(key)

    # key = gets.strip
    # c.add_input(
    #   case key
    #   when "a"
    #     -1
    #   when "d"
    #     1
    #   else
    #     0
    #   end
    # )
  rescue => e
    puts c.to_s
    raise e
  end
end
