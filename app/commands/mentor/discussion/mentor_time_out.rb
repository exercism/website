class Mentor::Discussion::MentorTimeOut
  include Mandate

  initialize_with :discussion

  def call
    discussion.mentor_timed_out!

    create_notifications!
  end

  private
  def create_notifications!
    User::Notification::Create.(
      discussion.student,
      :mentor_timed_out_discussion_student,
      discussion:
    )

    User::Notification::Create.(
      discussion.mentor,
      :mentor_timed_out_discussion_mentor,
      discussion:
    )
  end
end
