require 'http_authentication_token'

class Rack::Attack::Request
  extend Mandate::Memoize

  # Resolving a route from middleware is best-effort. recognize_path raises
  # RoutingError for anything the router doesn't know, but it can also raise
  # other things: paths mounted outside the router (/sidekiq) blow up with
  # NoMethodError because Warden isn't in the env yet, and route constraints
  # are arbitrary code that can fail in arbitrary ways.
  #
  # Every caller treats nil as "no route", so rescuing broadly is the safe
  # behaviour. The alternative is a throttle definition raising inside
  # middleware, which 500s the request before it ever reaches the app.
  memoize
  def routed_to
    route = Rails.application.routes.recognize_path(path, { method: request_method })
    "#{route[:controller]}##{route[:action]}"
  rescue StandardError
    nil
  end

  def throttle_key
    # Throttle on the route name to prevent calls to the same route
    # but with different params being counted separately
    "#{routed_to}|#{request_method}|#{http_auth_token || ip}"
  end

  def http_auth_token
    auth_header = env['HTTP_AUTHORIZATION']
    auth_header&.match(/^Bearer\s+(.+)$/)&.captures&.first
  end

  # In production we sit behind Cloudflare and then an ALB, which means the
  # X-Forwarded-For chain can resolve to a Cloudflare PoP address rather than
  # the real client. Throttling on that would throttle everyone behind the PoP.
  # CF-Connecting-IP is always set by Cloudflare and is always the true client IP.
  # It's only absent in local/test, where we fall back to req.ip.
  def client_ip
    env['HTTP_CF_CONNECTING_IP'].presence || ip
  end

  # Rack::Attack is middleware, so Devise's user_signed_in? isn't available.
  # The _exercism_user_id cookie is set for every signed-in user (see
  # ApplicationController#set_user_id_cookie) and is the same signal our
  # Cloudflare cache rules use to bypass the cache for logged-in users.
  def signed_in?
    cookies['_exercism_user_id'].present?
  end
end

Rack::Attack.throttled_response_retry_after_header = true

# Exempt verified search engine crawlers from all throttling, so that indexing
# is never collateral damage of a limit aimed at everything else.
#
# The X-Search-Engine header is set by a Cloudflare transform rule, which
# decides which crawlers we want to exempt. We deliberately do no user-agent
# matching here: a user agent is just a header and anyone can claim to be a
# search engine, so only Cloudflare - which verifies crawlers by IP ownership
# and reverse DNS - can answer this. Changing which engines are exempt is a
# change to that rule, not to this file.
#
# The header is trustworthy because:
# - The ALB security group only accepts traffic on 443 from Cloudflare's IP
#   ranges, so requests cannot reach us without passing through Cloudflare.
# - The transform rule *always* sets the header (to "false" when unverified),
#   so a client-supplied value can never survive to the origin.
Rack::Attack.safelist("verified search engines") do |req|
  req.env['HTTP_X_SEARCH_ENGINE'] == 'true'
end

# These two endpoints are cheap to request and expensive to serve, and are
# enumerable: there is one URL per exercise and one per submission, so anything
# walking the site systematically can pull an unbounded number of them. Cap
# unauthenticated access per-IP per-day. The limit is far above what any
# person browsing the site would reach.
CRAWLED_EXERCISE_PATH = %r{\A/tracks/[^/]+/exercises/[^/]+(/|\z)}
Rack::Attack.throttle("Unauthenticated crawling of expensive endpoints", limit: 500, period: 1.day) do |req|
  next unless req.get?
  next if req.signed_in?

  # Only resolve the route for the API endpoint, and only once we know the
  # path is in the right namespace: recognize_path walks the whole route set,
  # which is far too expensive to pay on every unauthenticated GET.
  matches = req.path.match?(CRAWLED_EXERCISE_PATH) ||
            (req.path.starts_with?('/api/v2/solutions') && req.routed_to == 'api/solutions/submission_files#index')
  next unless matches

  "unauthenticated-crawl|#{req.client_ip}"
end

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

Rack::Attack.throttle("API - GET solution files", limit: 20, period: 1.minute) do |req|
  # Sidekiq behaves differently with auth so we need this
  # else all sidekiq results will just fail
  next if req.path.starts_with?('/sidekiq')

  next unless req.get?
  next unless req.path.starts_with?('/api/v1/solutions')

  req.throttle_key
end

Rack::Attack.throttle("API - POST/PATCH/PUT/DELETE", limit: api_non_get_limit_proc, period: 1.minute) do |req|
  # Sidekiq behaves differently with auth so we need this
  # else all sidekiq results will just fail
  next if req.path.starts_with?('/sidekiq')

  next unless req.post? || req.patch? || req.put? || req.delete?
  next unless req.path.starts_with?('/api')

  req.throttle_key
end

Rack::Attack.throttle("API - export solutions", limit: 10, period: 1.week) do |req|
  # Sidekiq behaves differently with auth so we need this
  # else all sidekiq results will just fail
  next if req.path.starts_with?('/sidekiq')

  next unless req.get?
  next unless req.routed_to == 'api/export_solutions#index'

  req.throttle_key
end
