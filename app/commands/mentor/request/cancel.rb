class Mentor::Request::Cancel
  include Mandate

  initialize_with :request

  def call
    request.cancelled!
  end
end
