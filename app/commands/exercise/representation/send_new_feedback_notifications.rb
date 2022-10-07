class Exercise::Representation::SendNewFeedbackNotifications
  include Mandate

  queue_as :notifications

  initialize_with :representation

  def call = iterations.each { |iteration| send_notification(iteration) }

  private
  def iterations
    if representation.has_essential_feedback?
      latest_active_iterations
    elsif representation.has_actionable_feedback?
      latest_recent_active_iterations
    else
      raise "Incorrect feedback type"
    end
  end

  def submission_representations = representation.submission_representations
  def latest_active_iterations = submission_representations.map(&:iteration).select(&:latest?)

  def latest_recent_active_iterations
    latest_active_iterations.select { |iteration| iteration.created_at >= Time.zone.now - 2.weeks }
  end

  def send_notification(iteration)
    User::Notification::Create.(
      iteration.user,
      :analysis_feedback_added,
      iteration:,
      representation:
    )
  end
end
