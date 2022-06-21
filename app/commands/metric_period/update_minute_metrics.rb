class MetricPeriod::UpdateMinuteMetrics
  include Mandate

  def call
    metrics = Metric.
      where('created_at > ?', (Time.current.utc - 24.hours).beginning_of_hour).
      all.
      group_by { |m| [m.metric_action, m.track_id, m.created_at.hour] }

    metric_actions = MetricPeriod::Minute.metric_actions.keys.map(&:to_sym)
    tracks = Track.all
    hours = (0..23).to_a

    metric_actions.product(tracks, hours).each do |metric_action, track, hour|
      count = metrics[[metric_action, track.id, hour]].to_a.size

      metric = MetricPeriod::Minute.create_or_find_by!(metric_action:, track:, hour:) do |m|
        m.count = count
      end

      metric.update!(count:)
    end
  end
end
