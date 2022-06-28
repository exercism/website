class MetricPeriod::UpdateMonthMetrics
  include Mandate

  def initialize(month_to_update = Time.current.prev_month)
    @month_to_update = month_to_update.beginning_of_month
  end

  def call
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      generate_data!
    end
  end

  def generate_data!
    metric_actions.product(Track.all).each do |metric_action, track|
      count = metric_count(metric_action, track)

      MetricPeriod::Month.find_create_or_find_by!(metric_action:, track:, month: month_to_update.month) do |m|
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
      where('occurred_at >= ? AND occurred_at < ?', month_to_update, month_to_update.next_month).
      group_by { |m| [m.metric_action, m.track_id] }
  end
end
