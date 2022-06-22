class MetricPeriod::UpdateMinuteMetrics
  include Mandate

  def call
    current_minute = Time.current.beginning_of_minute
    previous_minute = Time.current.beginning_of_minute.prev_min

    metrics = Metric.
      where('created_at >= ? AND created_at < ?', previous_minute, current_minute).
      group_by { |m| [m.metric_action, m.track_id] }

    metric_actions = MetricPeriod::Minute.metric_actions.keys.map(&:to_sym)
    tracks = Track.all

    metric_actions.product(tracks).each do |metric_action, track|
      count = metrics[[metric_action, track.id]].to_a.size

      MetricPeriod::Minute.create_or_find_by!(metric_action:, track:, minute: previous_minute.min_of_day) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end
end
