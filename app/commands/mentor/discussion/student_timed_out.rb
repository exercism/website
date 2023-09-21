class Mentor::Discussion::StudentTimedOut
  include Mandate

  initialize_with :discussion

  def call
    discussion.transaction do
      update!
    end

    create_notifications!
  end

  private
  def update!
    cols = {
      status: :student_timed_out,
      awaiting_mentor_since: nil,
      awaiting_student_since: nil
    }
    unless discussion.finished_at
      cols[:finished_at] = Time.current
      cols[:finished_by] = :student_timed_out
    end
    discussion.update!(cols)
  end

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
