require 'http_authentication_token'

# Enable the Rack Attack cache store in test mode,
# as otherwise we can't verify limits being exceeded
Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new if Rails.env.test?

api_post_patch_limit_proc = proc do |req|
  next 4 if req.post? && req.path =~ %r{^/api/v2/solutions/[^/]+/iterations}
  next 12 if req.post? && req.path =~ %r{^/api/v2/solutions/[^/]+/submissions}
  next 30 if req.post? && req.path =~ %r{^/api/v2/markdown/parse}
  next 30 if req.patch? && req.path =~ %r{^/api/v2/mentoring/testimonials/[^/]+/reveal}
  next 20 if req.patch? && req.path =~ %r{^/api/v2/reputation/[^/]+/mark_as_seen}
  next 8 if req.patch? && req.path == '/api/v2/settings/communication_preferences'
  next 8 if req.patch? && req.path == '/api/v2/settings/sudo_update'

  5
end

Rack::Attack.throttle("API - POST and PATCH requests", limit: api_post_patch_limit_proc, period: 1.minute) do |req|
  if req.post? || req.patch?
    token = HttpAuthenticationToken.from_header(req.env['HTTP_AUTHORIZATION'])
    token || req.ip
  end
end
