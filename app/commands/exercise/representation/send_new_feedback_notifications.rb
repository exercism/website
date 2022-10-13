class Exercise::Representation::SendNewFeedbackNotifications
  include Mandate

  queue_as :notifications

  initialize_with :representation

  def call
    return unless representation.has_essential_feedback? || representation.has_actionable_feedback?

    iterations.each { |iteration| send_notification(iteration) }
  end

  private
  def iterations
    if representation.has_essential_feedback?
      latest_matching_iterations
    elsif representation.has_actionable_feedback?
      latest_recent_matching_iterations
    end
  end

  def latest_matching_iterations
    Iteration.latest.where(id: iterations_with_matching_ast_digest)
  end

  def latest_recent_matching_iterations
    latest_matching_iterations.where('iterations.created_at >= ?', Time.zone.now - 2.weeks)
  end

  def iterations_with_matching_ast_digest
    Submission::Representation.
      joins(submission: :iteration).
      where(ast_digest: representation.ast_digest).
      select('iterations.id')
  end

  def send_notification(iteration)
    User::Notification::Create.defer(
      iteration.user,
      :automated_feedback_added,
      iteration:,
      representation:
    )
  end
end
