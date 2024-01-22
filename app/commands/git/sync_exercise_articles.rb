class Git::SyncExerciseArticles
  include Mandate

  initialize_with :exercise

  def call = exercise.update(articles:)

  private
  def articles
    git_articles.articles.map.with_index do |article, index|
      Git::SyncExerciseArticle.(exercise, article, index + 1)
    end
  end

  def git_articles = Git::Exercise::Articles.new(exercise.slug, exercise.git_type, "HEAD", repo_url: exercise.track.repo_url)
end
