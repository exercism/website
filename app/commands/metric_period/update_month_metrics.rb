class MetricPeriod::UpdateMonthMetrics
  include Mandate

  def call
    current_month = Time.current.beginning_of_month
    previous_month = Time.current.beginning_of_month.prev_month

    metrics = Metric.
      where('created_at >= ? AND created_at < ?', previous_month, current_month).
      group_by { |m| [m.metric_action, m.track_id] }

    metric_actions = MetricPeriod::Month.metric_actions.keys.map(&:to_sym)
    tracks = Track.all

    metric_actions.product(tracks).each do |metric_action, track|
      count = metrics[[metric_action, track.id]].to_a.size

      MetricPeriod::Month.create_or_find_by!(metric_action:, track:, month: previous_month.month) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end
end
