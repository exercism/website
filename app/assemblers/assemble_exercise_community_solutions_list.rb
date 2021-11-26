class AssembleExerciseCommunitySolutionsList
  include Mandate

  initialize_with :exercise, :params

  def self.keys
    %i[criteria page tests_status mentoring_status up_to_date]
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
      criteria: params[:criteria],
      tests_status: params[:tests_status],
      mentoring_status: params[:mentoring_status],
      up_to_date: params[:up_to_date]
    )
  end
end
