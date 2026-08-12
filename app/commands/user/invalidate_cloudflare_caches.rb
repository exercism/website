# Purges every published solution page belonging to a user.
#
# NOTE: This is deliberately not wired up to anything. User-level data
# (reputation, flair, avatar, profile existence) is served from
# /api/v2/users/:handle.json rather than being baked into the cached HTML,
# so none of those changes need a purge. This exists for the one case that
# would need it: a handle change, as the handle is part of the URL.
# There is no handle-change path in the app today.
class User::InvalidateCloudflareCaches
  include Mandate

  queue_as :background

  initialize_with :user

  def call
    user.solutions.published.find_each do |solution|
      Solution::InvalidateCloudflareCache.defer(solution)
    end
  end
end
