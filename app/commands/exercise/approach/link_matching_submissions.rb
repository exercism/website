class Exercise::Approach::LinkMatchingSubmissions
  include Mandate

  initialize_with :approach

  delegate :exercise, to: :approach

  def call
    return relink_submissions!(linked_submissions) if approach.tags.blank?

    update_submissions!(linked_submissions)
    update_submissions!(unlinked_submissions)
  end

  private
  memoize
  def linked_submissions = Submission.where(exercise:).where(approach:)

  memoize
  def unlinked_submissions = Submission.where(exercise:).where(approach: nil)

  def update_submissions!(submissions)
    submissions.find_each do |submission|
      new_approach = approach.matching_tags?(submission.tags) ? approach : nil
      submission.update(approach: new_approach)
    end
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def relink_submissions!(submissions)
    submissions.find_each do |submission|
      Submission::LinkToMatchingApproach.defer(submission)
    end
  rescue StandardError => e
    Bugsnag.notify(e)
  end
end
