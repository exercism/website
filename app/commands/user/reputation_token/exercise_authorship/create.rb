class User
  class ReputationToken
    module ExerciseAuthorship
      class Create
        include Mandate

        initialize_with :authorship

        def call
          User::ReputationToken.create_or_find_by!(
            user: authorship.author,
            context_key: "authored_exercise/#{authorship.exercise.uuid}"
          ) do |rt|
            rt.context = authorship
            rt.reason = 'authored_exercise'
            rt.category = :authoring
          end
        end
      end
    end
  end
end
