class Git::SyncExerciseArticles
  include Mandate

  initialize_with :exercise

  def call
    fingerprint_before = articles_fingerprint

    exercise.update(articles:)

    # A force-sync runs this for every exercise on every track, so only purge
    # when the articles genuinely changed. Otherwise the weekly SyncTracksJob
    # would burst past Cloudflare's per-zone purge rate limits.
    ::Exercise::InvalidateCloudflareCache.defer(exercise) if articles_fingerprint != fingerprint_before
  end

  private
  # updated_at only moves when an article's content actually changes, so
  # this catches edits as well as additions and removals.
  def articles_fingerprint = exercise.articles.reload.pluck(:id, :updated_at).sort

  def articles
    git_articles.articles.map.with_index do |article, index|
      Git::SyncExerciseArticle.(exercise, article, index + 1)
    end
  end

  def git_articles = Git::Exercise::Articles.new(exercise.slug, exercise.git_type, "HEAD", repo_url: exercise.track.repo_url)
end
