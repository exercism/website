class Exercise
  class Authorship
    class Create
      include Mandate

      initialize_with :exercise, :author

      def call
        begin
          authorship = exercise.authorships.create!(author: author)
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        User::ReputationAcquisition.find_or_create_by!(
          user: author,
          reason_object: authorship,
          reason: "exercise_authorship",
          category: "exercise_authorship"
        )
      end
    end
  end
end
