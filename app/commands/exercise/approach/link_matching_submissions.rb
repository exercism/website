class Exercise::Approach::LinkMatchingSubmissions
  include Mandate

  initialize_with :approach

  def call
    # Check if the submissions currently linked to this approach should retain their
    # link to this approach. If not, check if they can be linked to another approach (or not)
    relink_matched_submissions!

    # Check if the submissions not yet linked to an approach, but that could be,
    # can be linked to this approach
    link_unmatched_submissions!
  end

  private
  def relink_matched_submissions!
    Submission.has_iteration.tagged.where(exercise:, approach:).find_each do |submission|
      next if approach.matches_tags?(submission.tags)

      Submission::LinkToMatchingApproach.defer(submission)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  def link_unmatched_submissions!
    Submission.has_iteration.tagged.where(exercise:, approach: nil).find_each do |submission|
      Submission::LinkApproach.(submission, approach) if approach.matches_tags?(submission.tags)
    rescue StandardError => e
      Bugsnag.notify(e)
    end
  end

  delegate :exercise, to: :approach
end
