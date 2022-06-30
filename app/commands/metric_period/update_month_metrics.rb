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
    metric_types.product(track_ids).each do |metric_type, track_id|
      count = metric_count(metric_type, track_id)

      MetricPeriod::Month.find_create_or_find_by!(metric_type:, track_id:, month:) do |m|
        m.count = count
      end.tap { |m| m.update!(count:) } # rubocop:disable Style/MultilineBlockChain
    end
  end

  private
  attr_reader :month_to_update

  def month =  month_to_update.month
  def track_ids = Track.pluck(:id).push(nil)
  def metric_types = Metric.subclasses.map(&:name)
  def metric_count(metric_type, track_id) = metrics[[metric_type, track_id]].to_a.size

  memoize
  def metrics
    Metric.
      where('occurred_at >= ? AND occurred_at < ?', month_to_update, month_to_update.next_month).
      group_by { |m| [m.type, m.track_id] }
  end
end
