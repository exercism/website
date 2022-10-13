# TODO: Award these on completed mentor discussion
# where rating is satisfactory or good.
class User::ReputationTokens::MentoredToken < User::ReputationToken
  params :discussion
  category :mentoring
  reason :mentored
  value 5

  before_validation on: :create do
    self.track = discussion.track unless track
    self.exercise = discussion.exercise unless exercise
    self.earned_on = discussion.finished_at unless earned_on
  end

  def guard_params = "Discussion##{discussion.id}"

  def i18n_params
    {
      student_handle: discussion.student_handle,
      exercise_title: discussion.exercise_title,
      track_title: discussion.track_title
    }
  end

  def internal_url
    Exercism::Routes.mentoring_discussion_url(discussion)
  end
end
