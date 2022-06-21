class MetricPeriod::UpdateHourMetrics
  include Mandate

  def call
    metrics = Metric.
      where('created_at > ?', (Time.current.utc - 24.hours).beginning_of_hour).
      all.
      group_by { |m| [m.action, m.track_id, m.created_at.hour] }

    actions = MetricPeriod::Hour.actions.keys.map(&:to_sym)
    tracks = Track.all
    hours = (0..23).to_a

    actions.product(tracks, hours).each do |action, track, hour|
      count = metrics[[action, track.id, hour]].to_a.size

      metric = MetricPeriod::Hour.create_or_find_by!(action:, track:, hour:) do |m|
        m.count = count
      end

      metric.update!(count:)
    end
  end
end
