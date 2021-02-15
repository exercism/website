class User
  class ReputationToken
    module ExerciseContributorship
      class Create
        include Mandate

        initialize_with :contributorship

        def call
          User::ReputationToken::Create.(
            contributorship.contributor,
            :exercise_contribution,
            contributorship: contributorship
          )
        end
      end
    end
  end
end
