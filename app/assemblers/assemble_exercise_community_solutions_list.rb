class AssembleExerciseCommunitySolutionsList
  include Mandate

  initialize_with :exercise, :params

  def self.permitted_params = [:page, :order, :criteria, { tags: [] }]

  def call
    SerializePaginatedCollection.(
      solutions,
      serializer: SerializeCommunitySolutions,
      meta: {
        unscoped_total: solutions.total_count
      }
    )
  end

  memoize
  def solutions
    Solution::SearchViaRepresentations.(
      exercise,
      page: params[:page],
      order: params[:order],
      criteria: params[:criteria],
      tags: params[:tags]
    )
  end
end
