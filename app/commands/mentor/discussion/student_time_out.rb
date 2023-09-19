class Mentor::Discussion::StudentTimeOut
  include Mandate

  initialize_with :discussion

  def call
    discussion.student_timed_out!

    create_notifications!
  end

  private
  def create_notifications!
    User::Notification::Create.(
      discussion.student,
      :student_timed_out_discussion_student,
      discussion:
    )

    User::Notification::Create.(
      discussion.mentor,
      :student_timed_out_discussion_mentor,
      discussion:
    )
  end
end
