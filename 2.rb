require "set"

if ARGV.length < 1
  input_path = "input/2.txt"
else
  input_path = "sample/2.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).strip
parsed = input.split(",").map(&:to_i)

def solve(code)
  n = code.size
  p = 0
  loop do
    break if p == n
    case code[p]
    when 1
      code[code[p + 3]] = code[code[p + 1]] + code[code[p + 2]]
      p += 4
    when 2
      code[code[p + 3]] = code[code[p + 1]] * code[code[p + 2]]
      p += 4
    when 99
      break
    end
  end

  code
end

def try(code, noun, verb)
  code[1] = noun
  code[2] = verb
  solve(code)
end

def ans(code)
  (0..99).each do |noun|
    (0..99).each do |verb|
      res = try(code.dup, noun, verb)
      return noun, verb if res[0] == 19690720
    end
  end
end

n, v = ans(parsed)
puts(100 * n + v)
