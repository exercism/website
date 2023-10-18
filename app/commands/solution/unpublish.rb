class Solution::Unpublish
  include Mandate

  initialize_with :solution

  def call
    solution.update!(published_iteration_id: nil, published_at: nil)
    Solution::UpdateTags.(solution)
    Solution::UpdatePublishedExerciseRepresentation.(solution)
    Solution::UpdateSnippet.(solution)
    Solution::UpdateNumLoc.(solution)

    update_num_published_solutions_on_exercise!
  end

  private
  def update_num_published_solutions_on_exercise!
    Exercise::CacheNumPublishedSolutions.defer(exercise)
  end

  delegate :exercise, to: :solution
end
