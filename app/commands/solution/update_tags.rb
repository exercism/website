class Solution::UpdateTags
  include Mandate

  initialize_with :solution

  # rubocop:disable Lint/UnreachableCode
  def call
    # We're not using these tags for now. We can always
    # recalculate them if we start to, but remove some of the
    # load in the system for now!
    return

    solution.update(tags:)
    Exercise::UpdateTags.(solution.exercise)
  end
  # rubocop:enable Lint/UnreachableCode

  private
  def tags
    return [] if latest_analysis.nil?

    analysis_tags = latest_analysis.tags
    existing_tags = Solution::Tag.where(solution:).where(tag: analysis_tags).select(:id, :tag).to_a
    solution_tags = existing_tags.map(&:tag)

    new_tags = (analysis_tags - solution_tags).map do |tag|
      Solution::Tag.find_create_or_find_by!(tag:, solution:)
    end

    existing_tags + new_tags
  end

  memoize
  def latest_analysis = solution.latest_published_iteration_submission&.analysis
end
