class Mentor::Discussion::NudgeStudent
  include Mandate

  initialize_with :discussion, :num_days_waiting

  def call
    User::Notification::Create.(
      discussion.student,
      :nudge_student_to_reply_in_discussion,
      discussion:,
      num_days_waiting:
    )
  end
end
