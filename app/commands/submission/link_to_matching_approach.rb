class Submission::LinkToMatchingApproach
  include Mandate

  initialize_with :submission

  def call
    submission.update(approach: matching_approach)
  end

  def matching_approach
    return nil if submission.tags.blank?

    submission.exercise.approaches.find do |approach|
      approach.matching_tags?(submission.tags)
    end
  end
end
