class Solution::InvalidateCloudflareCache
  include Mandate

  queue_as :background

  initialize_with :solution

  def call
    Cloudflare::PurgeUrls.(urls)
  end

  private
  # A published solution is reachable at two URLs: the handle-based one
  # and the legacy uuid-based one. Both need purging or the legacy path
  # carries on serving stale content.
  # See Tracks::CommunitySolutionsController#show
  def urls
    [
      url_for(solution.user.handle),
      url_for(solution.uuid)
    ]
  end

  def url_for(id)
    Exercism::Routes.track_exercise_solution_url(
      solution.track.slug,
      solution.exercise.slug,
      id
    )
  end
end
