class User
  class ReputationToken
    module ExerciseContributorship
      class Create
        include Mandate

        initialize_with :contributorship

        def call
          User::ReputationToken.find_or_create_by!(
            user: contributorship.contributor,
            context: contributorship,
            reason: :contributed_to_exercise,
            category: :authoring
          )
        end
      end
    end
  end
end
