#!/usr/bin/env ruby
# Split test files into batches of roughly equal duration and print
# them as a GitHub Actions matrix.
#
# Usage: split-tests.rb <batches> <timings.json> <files...>
#
# Files without a recorded timing are assumed to take the median time.
# A file that takes longer than its fair share of a batch is split by
# test into chunks (as "file:line:line..."), which `rails test` accepts.

require 'json'

batches = Integer(ARGV.shift)
timings = JSON.parse(File.read(ARGV.shift))
files = ARGV

known = files.filter_map { |f| timings[f] }.sort
median = known.empty? ? 1.0 : known[known.size / 2]
duration = ->(file) { timings[file] || median }
target = files.sum(&duration) / batches

# Each unit is [duration, "file" or "file:line:line..."]
units = files.flat_map do |file|
  source = File.readlines(file)
  lines = source.each_with_index.filter_map { |l, i| i + 1 if l.match?(/^\s*test\s+["']/) }
  chunks = (duration.(file) / (target / 2)).ceil

  # Only split files whose tests are all declared with `test "..."`, so no test is lost
  splittable = chunks >= 2 && lines.size >= chunks && source.none? { |l| l.match?(/^\s*def test_/) }
  next [[duration.(file), file]] unless splittable

  per_test = duration.(file) / lines.size
  lines.each_slice((lines.size.to_f / chunks).ceil).map do |slice|
    [per_test * slice.size, "#{file}:#{slice.join(':')}"]
  end
end

loads = Array.new(batches) { [0.0, []] }
units.sort_by { |d, _| -d }.each do |d, unit|
  batch = loads.min_by(&:first)
  batch[0] += d
  batch[1] << unit
end

matrix = loads.reject { |_, us| us.empty? }.map { |_, us| us.sort.join(" ") }
puts JSON.generate(tests: matrix)
