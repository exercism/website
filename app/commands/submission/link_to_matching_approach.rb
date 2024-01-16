class Submission::LinkToMatchingApproach
  include Mandate

  queue_as :solution_processing

  initialize_with :submission

  def call
    Submission::LinkApproach.(submission, matching_approach)
  end

  def matching_approach
    return nil if submission.tags.blank?
    return nil if submission.iteration.nil?

    submission.exercise.approaches.find do |approach|
      approach.matches_tags?(submission.tags)
    end
  end
end
