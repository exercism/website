class User::Notifications::StudentRepliedToDiscussionNotification < User::Notification
  params :discussion_post

  def url = discussion.mentor_url

  def i18n_params
    {
      student_name: student.handle,
      track_title: solution.track.title,
      exercise_title: solution.exercise.title
    }
  end

  def image_type = :avatar
  def image_url = student.avatar_url
  def guard_params = "DiscussionPost##{discussion_post.id}"

  delegate :discussion, to: :discussion_post

  private
  def student = solution.user

  def solution = discussion_post.solution
end
