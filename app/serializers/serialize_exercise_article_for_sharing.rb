class SerializeExerciseArticleForSharing
  include Mandate

  initialize_with :article

  def call
    {
      title: "Share this article",
      share_title: article.title,
      share_link: Exercism::Routes.track_exercise_article_url(article.track, article.exercise, article)
    }
  end
end
