class Delayed::Job
  self.abstract_class = true

  connects_to database: { writing: :dj, reading: :dj }
end
