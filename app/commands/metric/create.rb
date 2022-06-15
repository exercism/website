class Metric::Create
  include Mandate

  initialize_with :action, :created_at, :attributes

  def call = Metric.create!(action:, created_at:, **attributes)
end
