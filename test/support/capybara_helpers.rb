module CapybaraHelpers
  def use_capybara_host
    original_host = Rails.application.routes.default_url_options[:host]
    original_port = Rails.application.routes.default_url_options[:port]
    Rails.application.routes.default_url_options[:host] = Capybara.current_session.server.host
    Rails.application.routes.default_url_options[:port] = Capybara.current_session.server.port

    yield()

    Rails.application.routes.default_url_options[:host] = original_host
    Rails.application.routes.default_url_options[:port] = original_port
  end
end
