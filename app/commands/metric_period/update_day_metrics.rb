class MetricPeriod::UpdateDayMetrics
  include Mandate

  def call
    current_day = Time.current.beginning_of_day
    previous_day = Time.current.beginning_of_day.prev_day

    metrics = Metric.
      where('created_at >= ? AND created_at < ?', previous_day, current_day).
      group_by { |m| [m.metric_action, m.track_id] }

    metric_actions = MetricPeriod::Day.metric_actions.keys.map(&:to_sym)
    tracks = Track.all

    metric_actions.product(tracks).each do |metric_action, track|
      count = metrics[[metric_action, track.id]].to_a.size

      MetricPeriod::Day.create_or_find_by!(metric_action:, track:, day: previous_day.day) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end
end
