class MetricPeriod::UpdateMinuteMetrics
  include Mandate

  def call
    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Minute.create_or_find_by!(metric_action:, track:, minute: previous_minute.min_of_day) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  def metric_actions = MetricPeriod::Minute.metric_actions.keys.map(&:to_sym)
  def metric_count(metric_action, track) = metrics[[metric_action, track.id]].to_a.size

  memoize
  def metrics
    Metric.
      where('created_at >= ? AND created_at < ?', previous_minute, current_minute).
      group_by { |m| [m.metric_action, m.track_id] }
  end

  def current_minute = Time.current.beginning_of_minute
  def previous_minute = Time.current.beginning_of_minute.prev_min
end
