class Submission::LinkToMatchingApproach
  include Mandate

  initialize_with :submission

  def call
    submission.update(approach: matching_approach)
  end

  def matching_approach
    return nil unless submission.tags.present?

    submission.exercise.approaches.includes(:tags).find do |approach|
      approach.matching_tags?(submission.tags)
    end
  end
end
