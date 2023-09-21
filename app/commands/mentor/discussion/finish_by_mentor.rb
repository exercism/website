class Mentor::Discussion::FinishByMentor
  include Mandate

  initialize_with :discussion

  def call
    discussion.transaction do
      return if discussion.finished?

      update!
    end

    notify!
  end

  private
  def update!
    discussion.update!(
      status: :mentor_finished,
      finished_at: Time.current,
      finished_by: :mentor,
      awaiting_mentor_since: nil,
      awaiting_student_since: discussion.awaiting_student_since || Time.current
    )
  end

  def notify!
    User::Notification::Create.(
      discussion.student,
      :mentor_finished_discussion,
      discussion:
    )
  end
end
