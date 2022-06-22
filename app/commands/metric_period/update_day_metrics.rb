class MetricPeriod::UpdateDayMetrics
  include Mandate

  def call
    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Day.create_or_find_by!(metric_action:, track:, day: previous_day.day) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  def metric_actions = MetricPeriod::Day.metric_actions.keys.map(&:to_sym)
  def metric_count(metric_action, track) = metrics[[metric_action, track.id]].to_a.size

  memoize
  def metrics
    Metric.
      where('created_at >= ? AND created_at < ?', previous_day, current_day).
      group_by { |m| [m.metric_action, m.track_id] }
  end

  def current_day = Time.current.beginning_of_day
  def previous_day = Time.current.beginning_of_day.prev_day
end
