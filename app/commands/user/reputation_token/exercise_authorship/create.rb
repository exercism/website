class User
  class ReputationToken
    module ExerciseAuthorship
      class Create
        include Mandate

        initialize_with :authorship

        def call
          User::ReputationToken.create_or_find_by!(
            user: authorship.author,
            context: authorship,
            context_key: "authored_exercise/#{authorship.exercise.uuid}",
            reason: 'authored_exercise',
            category: :authoring
          )
        end
      end
    end
  end
end
