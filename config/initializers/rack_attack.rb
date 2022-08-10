require 'http_authentication_token'

Rack::Attack.throttled_response_retry_after_header = true

api_non_get_limit_proc = proc do |req|
  next 4 if req.post? && req.path =~ %r{^/api/v2/solutions/[^/]+/iterations}
  next 12 if req.post? && req.path =~ %r{^/api/v2/solutions/[^/]+/submissions}
  next 30 if req.post? && req.path =~ %r{^/api/v2/markdown/parse}
  next 30 if req.patch? && req.path =~ %r{^/api/v2/mentoring/testimonials/[^/]+/reveal}
  next 20 if req.patch? && req.path =~ %r{^/api/v2/reputation/[^/]+/mark_as_seen}
  next 8 if req.patch? && req.path == '/api/v2/settings/communication_preferences'
  next 8 if req.patch? && req.path == '/api/v2/settings/sudo_update'

  5
end

Rack::Attack.throttle("API - POST/PATCH/PUT/DELETE", limit: api_non_get_limit_proc, period: 1.minute) do |req|
  next unless req.post? || req.patch? || req.put? || req.delete?
  next unless req.path.starts_with?('/api')

  # We want to throttle on the route name, not the path as
  # calls to the same API method with different IDs has the same
  # route name, but different paths
  route_name = nil
  Rails.application.routes.router.recognize(req) do |route, _|
    route_name = route.name
  end
  token = HttpAuthenticationToken.from_header(req.env['HTTP_AUTHORIZATION'])

  "#{route_name}|#{req.request_method}|#{token || req.ip}"
end

Rack::Attack.throttle("API - export solutions", limit: 10, period: 1.week) do |req|
  next unless req.get?

  # We want to throttle on the route name, not the path as
  # calls to the same API method with different params have
  # the same route name, but different paths
  route_name = nil
  Rails.application.routes.router.recognize(req) do |route, _|
    route_name = route.name if route.name.present?
  end

  next unless route_name == 'api_track_exercise_export_solutions'

  token = HttpAuthenticationToken.from_header(req.env['HTTP_AUTHORIZATION'])
  token || req.ip
end
