require 'http_authentication_token'

class Rack::Attack::Request
  extend Mandate::Memoize

  memoize
  def routed_to
    route = Rails.application.routes.recognize_path(path, { method: request_method })
    "#{route[:controller]}##{route[:action]}"
  rescue ActionController::RoutingError
    nil
  end

  def throttle_key
    # Throttle on the route name to prevent calls to the same route
    # but with different params being counted separately
    "#{routed_to}|#{request_method}|#{http_auth_token || ip}"
  end

  def http_auth_token = HttpAuthenticationToken.from_header(env['HTTP_AUTHORIZATION'])
end

Rack::Attack.throttled_response_retry_after_header = true

api_non_get_limit_proc = proc do |req|
  next 4 if req.post? && req.routed_to == 'api/iterations#create'
  next 12 if req.post? && req.routed_to == 'api/solutions/submissions#create'
  next 30 if req.post? && req.routed_to == 'api/markdown#parse'
  next 30 if req.patch? && req.routed_to == 'api/mentoring/testimonials#reveal'
  next 30 if req.patch? && req.routed_to == 'api/tracks/trophies#reveal'
  next 20 if req.patch? && req.routed_to == 'api/reputation#mark_as_seen'
  next 20 if req.patch? && req.routed_to == 'api/settings/user_preferences#update'
  next 8 if req.patch? && req.routed_to == 'api/settings/communication_preferences#update'
  next 8 if req.patch? && req.routed_to == 'api/settings#sudo_update'
  next 10 if req.patch? && req.routed_to == 'api/mentoring/representations#update'

  5
end

Rack::Attack.throttle("API - POST/PATCH/PUT/DELETE", limit: api_non_get_limit_proc, period: 1.minute) do |req|
  next unless req.post? || req.patch? || req.put? || req.delete?
  next unless req.path.starts_with?('/api')
  next if req.path.starts_with?('/sidekiq')

  req.throttle_key
end

Rack::Attack.throttle("API - export solutions", limit: 10, period: 1.week) do |req|
  next unless req.get?
  next if req.path.starts_with?('/sidekiq')
  next unless req.routed_to == 'api/export_solutions#index'

  req.throttle_key
end
