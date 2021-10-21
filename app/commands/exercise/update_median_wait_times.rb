class Exercise
  class UpdateMedianWaitTimes
    include Mandate

    def call
      Exercise.find_each do |exercise|
        exercise.update(median_wait_time: median_wait_time(exercise))
      end
    end

    private
    def median_wait_time(exercise)
      wait_times = Mentor::Discussion.
        joins(:request).
        select('TIMESTAMPDIFF(SECOND, request.created_at, mentor_discussions.created_at) AS wait_time').
        where('request.exercise_id': exercise.id).
        map(&:wait_time)

      calculate_median(wait_times)
    end

    def calculate_median(vals)
      return nil if vals.empty?

      vals.sort!
      (vals[(vals.length - 1) / 2] + vals[vals.length / 2]) / 2.0
    end
  end
end
