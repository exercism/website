class Exercise::InvalidateCloudflareCache
  include Mandate

  queue_as :background

  initialize_with :exercise

  def call
    Cloudflare::PurgeUrls.(urls)
  end

  private
  # The dig deeper page lists an exercise's approaches and articles, so it
  # goes stale whenever any of them do. The approach and article pages
  # cross-link to each other, so the whole set gets purged together.
  def urls
    [
      Exercism::Routes.track_exercise_url(track, exercise),
      Exercism::Routes.track_exercise_dig_deeper_url(track, exercise),
      *exercise.approaches.map { |approach| Exercism::Routes.track_exercise_approach_url(track, exercise, approach) },
      *exercise.articles.map { |article| Exercism::Routes.track_exercise_article_url(track, exercise, article) }
    ]
  end

  def track = exercise.track
end
