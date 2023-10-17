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

    latest_analysis.tags.map do |tag|
      Solution::Tag.find_or_create_by(tag:, solution:)
    end
  end

  memoize
  def latest_analysis = solution.latest_published_iteration_submission&.analysis
end
