class Track
  class UpdateMedianWaitTimes
    include Mandate

    def call
      Track.active.find_each do |track|
        track.update(median_wait_time: median_wait_time(track))
      end
    end

    private
    def median_wait_time(track)
      wait_times = Mentor::Discussion.
        joins(:request).
        joins(:exercise).
        where('exercise.track_id': track.id).
        select('TIMESTAMPDIFF(SECOND, mentor_requests.created_at, mentor_discussions.created_at) AS wait_time').
        where('mentor_discussions.created_at > ?', Time.current - 4.weeks).
        map(&:wait_time).
        reject(&:zero?)

      calculate_median(wait_times)
    end

    def calculate_median(vals)
      return nil if vals.empty?

      vals.sort!
      (vals[(vals.length - 1) / 2] + vals[vals.length / 2]) / 2.0
    end
  end
end
