class User
  class ReputationToken
    module ExerciseContributorship
      class Create
        include Mandate

        initialize_with :contributorship

        def call
          User::ReputationToken.create_or_find_by!(
            user: contributorship.contributor,
            context: contributorship,
            context_key: "contributed_to_exercise/#{contributorship.exercise.uuid}",
            reason: 'contributed_to_exercise',
            category: :authoring
          )
        end
      end
    end
  end
end
