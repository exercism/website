class User
  class ReputationToken
    module ExerciseContributorship
      class Create
        include Mandate

        initialize_with :contributorship

        def call
          User::ReputationToken::Create.(
            contributorship.contributor,
            "contributed_to_exercise/#{contributorship.exercise.uuid}",
            :authoring,
            :contributed_to_exercise,
            context: contributorship,
            exercise: contributorship.exercise,
            track: contributorship.exercise.track
          )
        end
      end
    end
  end
end
