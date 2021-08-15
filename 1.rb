require "set"

if ARGV.length < 1
  input_path = "input/1.txt"
else
  input_path = "sample/1.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map(&:to_i)

# take its mass, divide by three, round down, and subtract 2.
def fuel(mass)
  f = (mass.to_i / 3).to_i - 2
  f <= 0 ? 0 : f
end

def rec(mass)
  sum = 0
  loop do
    f = fuel(mass)
    return sum if f == 0
    sum += f
    mass = f
  end
end

ans = parsed.map { |p| rec(p) }.sum

puts(ans)
