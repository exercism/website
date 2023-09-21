class Mentor::Discussion::AwaitingStudent
  include Mandate

  initialize_with :discussion

  def call
    discussion.transaction do
      return if discussion.mentor_finished? || discussion.finished?

      discussion.update!(
        status: :awaiting_student,
        awaiting_mentor_since: nil,
        awaiting_student_since: discussion.awaiting_student_since || Time.current
      )
    end
  end
end
