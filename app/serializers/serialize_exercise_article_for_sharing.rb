class SerializeExerciseArticleForSharing
  include Mandate

  initialize_with :article

  def call
    {
      title: I18n.t("serializers.exercise_article_for_sharing.title"),
      share_title: article.title,
      share_link: Exercism::Routes.track_exercise_article_url(article.track, article.exercise, article)
    }
  end
end
