class Mentor::Discussion::AwaitingMentor
  include Mandate

  initialize_with :discussion

  def call
    discussion.transaction do
      return if discussion.mentor_finished? || discussion.finished?

      discussion.update!(
        status: :awaiting_mentor,
        awaiting_mentor_since: discussion.awaiting_mentor_since || Time.current,
        awaiting_student_since: nil
      )
    end
  end
end
