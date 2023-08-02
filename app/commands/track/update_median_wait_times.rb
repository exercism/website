class Track::UpdateMedianWaitTimes
  include Mandate

  def call
    Track.active.find_each do |track|
      # Use update_column. We don't want to touch updated_at
      track.update_column(:median_wait_time, median_wait_time(track))
    end
  end

  private
  def median_wait_time(track)
    wait_times = Mentor::Discussion.
      joins(:request).
      joins(:exercise).
      where('exercise.track_id': track.id).
      where('mentor_discussions.created_at > ?', Time.current - 4.weeks).
      select('TIMESTAMPDIFF(SECOND, mentor_requests.created_at, mentor_discussions.created_at) AS wait_time').
      map(&:wait_time).
      reject { |seconds| seconds < 5 }

    calculate_median(wait_times)
  end

  def calculate_median(vals)
    return nil if vals.empty?

    vals.sort!
    (vals[(vals.length - 1) / 2] + vals[vals.length / 2]) / 2.0
  end
end
