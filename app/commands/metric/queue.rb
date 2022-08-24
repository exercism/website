class Metric::Queue
  include Mandate

  initialize_with :type, :occurred_at, attributes: Mandate::KWARGS

  def call
    return if user&.ghost?
    return if user&.system?

    attributes[:request_context] = Exercism.request_context
    Metric::Create.defer(type, occurred_at, **attributes)
  rescue StandardError => e
    # Don't crash if the creation fails, e.g. if sidekiq is down
    Bugsnag.notify(e)
  end

  memoize
  def user = attributes[:user]
end
