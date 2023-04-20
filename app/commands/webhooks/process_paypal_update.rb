class Webhooks::ProcessPaypalUpdate
  include Mandate

  initialize_with :event_type, :id, :resource

  def call
    # TODO
  end
end
