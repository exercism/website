class MetricPeriod::UpdateMonthMetrics
  include Mandate

  def call
    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Month.create_or_find_by!(metric_action:, track:, month: previous_month.month) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  def metric_actions = MetricPeriod::Month.metric_actions.keys.map(&:to_sym)
  def metric_count(metric_action, track) = metrics[[metric_action, track.id]].to_a.size

  memoize
  def metrics
    Metric.
      where('created_at >= ? AND created_at < ?', previous_month, current_month).
      group_by { |m| [m.metric_action, m.track_id] }
  end

  def current_month = Time.current.beginning_of_month
  def previous_month = Time.current.beginning_of_month.prev_month
end
