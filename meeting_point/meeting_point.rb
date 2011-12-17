def dist a, b
  (0..1).to_a.map{ |i| (a[i] - b[i]).abs }.max
end

n = gets.to_i
#n = 100000

houses = []

sum_x = 0
sum_y = 0

n.times do |i|
  house =  gets.split.map{|coords| coords.to_i }
  #house =  [rand(10**9), rand(10**9)]#gets.split.map{|coords| coords.to_i }

  sum_x += house[0]
  sum_y += house[1]

  houses << house
end

center = [sum_x / n, sum_y / n]

selected_houses = houses.sort do |a,b|
  dist(a,center) <=> dist(b, center)
end

selected_houses = selected_houses[0..3]

paths = selected_houses.map do |house|
  houses.inject(0) { |a, meeting| a + dist(meeting, house) }
end

puts paths.min
