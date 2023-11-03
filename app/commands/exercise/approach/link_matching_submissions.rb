class Exercise::Approach::LinkMatchingSubmissions
  include Mandate

  initialize_with :approach

  def call
    return relink_submissions!(linked_submissions) if approach.tags.empty?
    else
      update_submissions!(linked_submissions)
      update_submissions!(unlinked_submissions)
    end
  end

  private
  memoize
  def analyzed_exercise_submissions
    Submission.includes(:analysis).
      where(exercise: approach.exercise).
      where(analysis_status: :completed)
  end

  memoize
  def linked_submissions = analyzed_exercise_submissions.where(approach:)

  memoize
  def unlinked_submissions = analyzed_exercise_submissions.where(approach: nil)

  def update_submissions!(submissions)
    submissions.includes(:analysis).find_each do |submission|
      new_approach = approach.matching_tags?(submission.tags) ? approach : nil
      submission.update(approach: new_approach)
    end
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  def relink_submissions!(submissions)
    submissions.includes(:analysis).find_each do |submission|
      Submission::LinkToMatchingApproach.defer(submission)
    end
  rescue StandardError => e
    Bugsnag.notify(e)
  end
end
