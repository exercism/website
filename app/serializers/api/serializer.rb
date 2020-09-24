class API::Serializer
  include Rails.application.routes.url_helpers
  include Mandate

  def to_json(*_args)
    to_hash.to_json
  end
end
