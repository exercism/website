class MetricPeriod::UpdateMonthMetrics
  include Mandate

  def initialize(month_to_update = Time.current.prev_month)
    @month_to_update = month_to_update.beginning_of_month
  end

  def call
    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Month.create_or_find_by!(metric_action:, track:, month: month_to_update.month) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  attr_reader :month_to_update

  def metric_actions = MetricPeriod::Month.metric_actions.keys.map(&:to_sym)
  def metric_count(metric_action, track) = metrics[[metric_action, track.id]].to_a.size

  memoize
  def metrics
    Metric.
      where('created_at >= ? AND created_at < ?', month_to_update, month_to_update.next_month).
      group_by { |m| [m.metric_action, m.track_id] }
  end
end
