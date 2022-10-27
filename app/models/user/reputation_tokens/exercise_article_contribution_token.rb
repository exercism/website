class User::ReputationTokens::ExerciseArticleContributionToken < User::ReputationToken
  params :contributorship
  category :authoring
  reason :contributed_to_exercise_article
  value 5 # TODO: determine value

  before_validation on: :create do
    self.exercise = contributorship.article.exercise unless exercise
    self.track = contributorship.article.track unless track
    self.earned_on = contributorship.created_at unless earned_on
  end

  def i18n_params = { article_title: contributorship.article.title, exercise_title: exercise.title }
  def guard_params = "Article##{contributorship.article.id}"
  def internal_url = Exercism::Routes.track_exercise_article_path(track, exercise, contributorship.article)
end
