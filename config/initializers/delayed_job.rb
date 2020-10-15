# class Delayed::Backend::ActiveRecord::Job
#  self.abstract_class = true
#
#  connects_to database: { writing: :dj, reading: :dj }
# end

Delayed::Backend::ActiveRecord::Job.establish_connection :dj
