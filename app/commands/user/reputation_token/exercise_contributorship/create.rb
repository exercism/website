class User
  class ReputationToken
    module ExerciseContributorship
      class Create
        include Mandate

        initialize_with :contributorship

        def call
          User::ReputationToken.find_or_create_by!(
            user: contributorship.contributor,
            reason_object: contributorship,
            reason: :exercise_contributorship,
            category: "exercise_contributorship"
          )
        end
      end
    end
  end
end
