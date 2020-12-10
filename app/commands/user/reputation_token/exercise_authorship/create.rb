class User
  class ReputationToken
    module ExerciseAuthorship
      class Create
        include Mandate

        initialize_with :authorship

        def call
          User::ReputationToken.find_or_create_by!(
            user: authorship.author,
            reason_object: authorship,
            reason: :exercise_authorship,
            category: "exercise_authorship"
          )
        end
      end
    end
  end
end
