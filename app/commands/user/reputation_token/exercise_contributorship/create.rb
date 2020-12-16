class User
  class ReputationToken
    module ExerciseContributorship
      class Create
        include Mandate

        initialize_with :contributorship

        def call
          User::ReputationToken.create_or_find_by!(
            user: contributorship.contributor,
            context_key: "contributed_to_exercise/#{contributorship.exercise.uuid}"
          ) do |rt|
            rt.context = contributorship
            rt.reason = :contributed_to_exercise
            rt.category = :authoring
          end
        end
      end
    end
  end
end
