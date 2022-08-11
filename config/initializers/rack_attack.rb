# require 'http_authentication_token'

# class Rack::Attack::Request
#   extend Mandate::Memoize

#   def auth_token
#     HttpAuthenticationToken.from_header(env['HTTP_AUTHORIZATION'])
#   end

#   memoize
#   def route_name
#     route_name = nil
#     Rails.application.routes.router.recognize(self) do |route|
#       route_name = route.name if route.name.present?
#     end
#     route_name
#   end
# end

# Rack::Attack.throttled_response_retry_after_header = true

# api_non_get_limit_proc = proc do |req|
#   next 4 if req.post? && req.route_name == 'api_solution_iterations'
#   next 12 if req.post? && req.route_name == 'api_solution_submissions'
#   next 30 if req.post? && req.route_name == 'api_parse_markdown'
#   next 30 if req.patch? && req.route_name == 'reveal_api_mentoring_testimonial'
#   next 20 if req.patch? && req.route_name == 'mark_as_seen_api_reputation'
#   next 8 if req.patch? && req.route_name == 'api_settings_communication_preferences'
#   next 8 if req.patch? && req.route_name == 'sudo_update_api_settings'

#   5
# end

# Rack::Attack.throttle("API - POST/PATCH/PUT/DELETE", limit: api_non_get_limit_proc, period: 1.minute) do |req|
#   next unless req.post? || req.patch? || req.put? || req.delete?
#   next unless req.path.starts_with?('/api')

#   # Throttle on the route name to prevent calls to the same route
#   # but with different params being counted separately
#   "#{req.route_name}|#{req.request_method}|#{req.auth_token || req.ip}"
# end

# Rack::Attack.throttle("API - export solutions", limit: 10, period: 1.week) do |req|
#   next unless req.get? && req.route_name == 'api_track_exercise_export_solutions'

#   req.auth_token || req.ip
# end
