# Caching

Exercism sits behind Cloudflare. Most of the caching work happens at the edge rather
than in Rails, so the important question for any response is usually "will Cloudflare
store this?" rather than "is there a fragment cache?".

## Edge caching of HTML pages

`ApplicationController#cache_public_action!` is the single entry point. Add it as a
`before_action` on any public, signed-out-identical page:

```ruby
before_action :cache_public_action!, only: %i[show]
```

It deliberately no-ops in four cases:

- Devise controllers (the sign-in form carries a session-bound CSRF token)
- Test and development environments
- Signed-in users
- Anyone carrying the `_exercism_user_id` cookie

That last one is the safety net. `set_user_id_cookie` sets a signed `_exercism_user_id`
cookie for every signed-in user, and Cloudflare is configured to bypass the cache when
it is present. It means a cached signed-out page can never be served to a signed-in
user, even if the Rails-side check is wrong.

### Two TTL modes

Without arguments the action gets a random 5-20 minute TTL. The jitter is intentional:
a fixed TTL makes everything expire at once and produces traffic spikes at origin.

With `edge_ttl:`, the browser TTL drops to one second and the edge TTL becomes the value
given (jittered by up to 10%). Use this when the page needs to live at the edge for a
long time but must be purgeable on demand, because purging Cloudflare cannot purge
browser caches. The short browser TTL is what makes a purge authoritative everywhere.

```ruby
def cache_public_page!
  cache_public_action!(edge_ttl: 1.day)
end
```

Pages using the long-TTL mode need a matching purge path. `Cloudflare::PurgeUrls` is the
primitive; see `Solution::InvalidateCloudflareCache`, `Track::InvalidateCloudflareCache`
and `User::InvalidateCloudflareCaches` for how a model change fans out to the URLs that
render it. Purge every URL a record is reachable at, not just the canonical one.

## Attachments and images

**Attachments must resolve to the proxy route, never the redirect route.**
`config.active_storage.resolve_model_to_route` is set to `:rails_storage_proxy` in
`config/application.rb`, so `image_tag partner.light_logo` produces a proxy URL.

The default redirect route cannot be cached at the edge, for two independent reasons:

1. `ActiveStorage::Blobs::RedirectController#show` calls
   `expires_in ActiveStorage.service_urls_expire_in` with no `public: true`, so the
   response is `Cache-Control: private` and Cloudflare skips it outright.
2. It 302s to a presigned S3 URL, so the redirect can never be cached for longer than
   the signature lives, no matter what headers it carries.

`ActiveStorage::Blobs::ProxyController` has neither problem. It serves the bytes from a
permanent URL under `http_cache_forever public: true` and includes
`ActiveStorage::DisableSession`, so there is no `Set-Cookie` to trip the edge either.
The cost is that a cache miss streams bytes through a Rails process; that is one miss
per PoP per blob, which is the right trade for anything on a hot page.

`config.active_storage.service_urls_expire_in` still applies to code that asks a blob
for its service URL directly (direct downloads, the admin UI).

User avatars mostly do not go through ActiveStorage at all: `AvatarsController` serves
them with a version in the path and `expires_in 5.years, public: true`. Raising
`user.version` is what busts that cache.

## Things that silently break edge caching

- A `Set-Cookie` on the response. Cloudflare will not cache it.
- A redirect from an `ApplicationController` action. `disable_cache_for_redirects`
  forces `no-store` on these, so a cached page can never send a user to the wrong place.
- `private` in `Cache-Control`, which is what bare `expires_in` produces. Public
  responses need `public: true` passed explicitly.
- The `Vary` header. `set_vary_header` adds `Accept`, `Host` and `Turbo-Frame`; adding
  anything high-cardinality there fragments the cache badly.

## Below the edge

- `Cache::GenerateEtag` builds per-user etags for `stale?`, letting signed-in requests
  return 304 without rendering.
- `Solution::CachedSerializedView` stores serialized payloads in S3 for expensive pages,
  invalidated alongside the Cloudflare purge.
- `Rails.cache` (Redis) for expensive computations, per the usual fragment caching rules.
