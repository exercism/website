class Solution::UpdateTags
  include Mandate

  initialize_with :solution

  def call
    solution.update(tags:)
    Exercise::UpdateTags.(solution.exercise)
  end

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
