module TimeExtensions
  def min_of_day
    hour * 60 + min
  end
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
