#!/usr/bin/env ruby
# Split test files into batches of roughly equal duration and print
# them as a GitHub Actions matrix.
#
# Usage: split-tests.rb <batches> <timings.json> <files...>
#
# Files without a recorded timing are assumed to take the median time.

require 'json'

batches = Integer(ARGV.shift)
timings = JSON.parse(File.read(ARGV.shift))
files = ARGV

known = files.filter_map { |f| timings[f] }.sort
median = known.empty? ? 1.0 : known[known.size / 2]

loads = Array.new(batches) { [0.0, []] }
files.sort_by { |f| -(timings[f] || median) }.each do |file|
  batch = loads.min_by(&:first)
  batch[0] += timings[file] || median
  batch[1] << file
end

matrix = loads.reject { |_, fs| fs.empty? }.map { |_, fs| fs.sort.join(" ") }
puts JSON.generate(tests: matrix)
