class User::Notifications::MentorStartedDiscussionNotification < User::Notification
  params :discussion, :discussion_post

  before_validation on: :create do
    self.track = solution.track
    self.exercise = solution.exercise
  end

  def url = discussion.student_url

  def i18n_params
    {
      mentor_name: mentor.handle,
      track_title: track.title,
      exercise_title: exercise.title
    }
  end

  def image_type = :avatar
  def image_url = mentor.avatar_url
  def guard_params = "Discussion##{discussion.id}"

  private
  def solution = discussion.solution

  def mentor = discussion.mentor
end
