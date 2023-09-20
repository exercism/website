class Mentor::Discussion::AbandonedByStudent
  include Mandate

  initialize_with :discussion

  def call
    discussion.update!(
      status: :finished,
      awaiting_mentor_since: nil,
      awaiting_student_since: nil
    )
  end
end
