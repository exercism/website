class Delayed::Job
  connects_to database: { writing: :dj, reading: :dj }
end
