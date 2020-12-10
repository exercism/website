class User
  class ReputationToken
    module ExerciseAuthorship
      class Create
        include Mandate

        initialize_with :authorship

        def call
          User::ReputationToken.find_or_create_by!(
            user: authorship.author,
            context: authorship,
            reason: :authored_exercise,
            category: :authoring
          )
        end
      end
    end
  end
end
