class User::ReputationTokens::ExerciseArticleAuthorToken < User::ReputationToken
  params :authorship
  category :authoring
  reason :authored_exercise_article
  value 12 # TODO: determine value

  before_validation on: :create do
    self.exercise = authorship.article.exercise unless exercise
    self.track = authorship.article.track unless track
    self.earned_on = authorship.created_at unless earned_on
  end

  def i18n_params = { article_title: authorship.article.title, exercise_title: exercise.title }
  def guard_params = "Article##{authorship.article.id}"
  def internal_url = Exercism::Routes.track_exercise_article_path(track, exercise, authorship.article)
end
