class Exercise::Approach::LinkMatchingSubmissions
  include Mandate

  initialize_with :approach

  def call
    return relink_submissions! if approach.tags.blank?

    update_submissions!(linked_submissions)
    update_submissions!(unlinked_submissions.tagged)
  end

  private
  def linked_submissions = Submission.where(exercise:, approach:)
  def unlinked_submissions = Submission.where(exercise:, approach: nil)

  def update_submissions!(submissions)
    submissions.find_each do |submission|
      new_approach = approach.matches_tags?(submission.tags) ? approach : nil
      submission.update(approach: new_approach)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def relink_submissions!
    linked_submissions.find_each do |submission|
      Submission::LinkToMatchingApproach.defer(submission)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  delegate :exercise, to: :approach
end
