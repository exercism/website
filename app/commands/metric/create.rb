class Metric::Create
  include Mandate

  initialize_with :metric_action, :created_at, :attributes

  def call = Metric.create!(metric_action:, created_at:, **attributes)
end
