require "set"

if ARGV.length < 1
  input_path = "input/4.txt"
else
  input_path = "sample/4.txt"
end

puts "Load input from #{input_path}"

input = File.read(input_path).split("\n").map(&:strip)
parsed = input.map do |line|
  match = /(\d+)\-(\d+)/.match(line)
  [match[1].to_i, match[2].to_i]
end
n1, n2 = parsed[0]

def meet?(n)
  ns = n.to_s
  return false if ns.size != 6
  (1...6).each do |i|
    return false if ns[i] < ns[i - 1]
  end
  rep = 1
  prv = ns[0]
  (1...6).each do |i|
    if prv == ns[i]
      rep += 1
    else
      break if rep == 2
      rep = 1
    end
    prv = ns[i]
  end

  return false if rep != 2

  true
end

puts((n1..n2).count { |n| meet?(n) })
