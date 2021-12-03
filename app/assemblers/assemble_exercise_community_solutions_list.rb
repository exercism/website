class AssembleExerciseCommunitySolutionsList
  include Mandate

  initialize_with :exercise, :params

  def self.keys
    %i[page order criteria up_to_date passed_tests not_passed_head_tests]
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
      order: params[:order],
      criteria: params[:criteria],
      sync_status: params[:up_to_date].present? ? :up_to_date : nil,
      tests_status: params[:passed_tests].present? ? :passed : nil,
      head_tests_status: params[:not_passed_head_tests].present? ? nil : %i[queued passed]
    )
  end
end
