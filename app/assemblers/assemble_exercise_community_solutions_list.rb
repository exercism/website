class AssembleExerciseCommunitySolutionsList
  include Mandate

  initialize_with :exercise, :params

  def self.keys
    %i[criteria page]
  end

  def call
    SerializePaginatedCollection.(
      solutions,
      serializer: SerializeCommunitySolutions,
      meta: {
        unscoped_total: exercise.solutions.published.count
      }
    )
  end

  memoize
  def solutions
    Solution::SearchCommunitySolutions.(
      exercise,
      page: params[:page],
      criteria: params[:criteria]
    )
  end
end
