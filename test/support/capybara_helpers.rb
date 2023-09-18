# This helper is for us to be able to correctly produce links that point to our
# capybara server. This is needed when testing the creation of iteration as to
# do it is produced dynamically within the serializer.
module CapybaraHelpers
  def use_capybara_host
    original_host = Rails.application.routes.default_url_options[:host]
    original_port = Rails.application.routes.default_url_options[:port]
    Rails.application.routes.default_url_options[:host] = Capybara.current_session.server.host
    Rails.application.routes.default_url_options[:port] = Capybara.current_session.server.port

    # Regenerate the summaries to avoid n+1 warnings
    UserTrack.all.each { |ut| ut.send(:summary) }

    yield()

    Rails.application.routes.default_url_options[:host] = original_host
    Rails.application.routes.default_url_options[:port] = original_port
  end
end
