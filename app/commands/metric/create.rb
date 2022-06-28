class Metric::Create
  include Mandate

  initialize_with :metric_action, :occurred_at, :attributes

  def call = Metric.create!(metric_action:, occurred_at:, **attributes)
end
