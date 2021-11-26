class AssembleExerciseCommunitySolutionsList
  include Mandate

  initialize_with :exercise, :params

  def self.keys
    %i[page order criteria tests_status mentoring_status sync_status]
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
      **params.slice(:page, :order, :criteria, :tests_status, :mentoring_status, :sync_status).to_hash.symbolize_keys
    )
  end
end
