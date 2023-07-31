module TimeExtensions
  def min_of_day = hour * 60 + min
  def prev_min = self - 1.minute
  def next_min = self + 1.minute
end

class Time
  include TimeExtensions
end

class DateTime
  include TimeExtensions
end

class ActiveSupport::TimeWithZone
  include TimeExtensions
end
