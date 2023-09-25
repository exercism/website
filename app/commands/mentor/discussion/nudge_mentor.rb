class Mentor::Discussion::NudgeMentor
  include Mandate

  initialize_with :discussion, :num_days_waiting

  def call
    User::Notification::Create.(
      discussion.mentor,
      :nudge_mentor_to_reply_in_discussion,
      discussion:,
      num_days_waiting:
    )
  end
end
