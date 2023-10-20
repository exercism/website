class AssembleExerciseCommunitySolutionsList
  include Mandate

  initialize_with :exercise, :params

  def self.keys = %i[page order criteria]

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
      criteria: params[:criteria]
    )
  end
end
