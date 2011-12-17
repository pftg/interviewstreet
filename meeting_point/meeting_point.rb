require 'benchmark'

class Array
    def sum
        self.inject{|sum,x| sum + x }
    end
end

houses = []
paths = []
#n = 10000#gets.to_i
n = 4
#i_houses = Array.new(n){[rand(1000000000), rand(1000000000)]}
i_houses = [[0,0],[3,4],[1,3],[1,2]]

puts 'Start!'
tm = Benchmark.measure do
  min_dist = 0

  n.times do |i|
    house =  i_houses[i] #gets.split.map{|coords| coords.to_i }
    max_edge = [1,2].map {|i| [max_edge[i], house[i]].max }
    min_edge = [1,2].map {|i| [min_edge[i], house[i]].max }
    if !edge || house == edge

    dist = [(to_m[0] - house[0]).abs,(to_m[1] - house[1]).abs].max
    path_to_add = 0
    min_dist = nil

    houses.each_with_index { |to_m, i|
      dist = [(to_m[0] - house[0]).abs,(to_m[1] - house[1]).abs].max
      d = paths[i] += dist
      #min_dist = d if min_dist && min_dist > d

      path_to_add += dist
    }

    houses << house
    paths << path_to_add
  end

  p paths
  puts paths.min
  #puts min_dist
end
puts "Time: #{tm}"
