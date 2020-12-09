class Exercise
  class Authorship
    class Create
      include Mandate

      initialize_with :exercise, :author

      def call
        authorship = exercise.authorships.create!(author: author)
        User::ReputationAcquisition.find_or_create_by!(
          user: author,
          reason_object: authorship,
          reason: "exercise_authorship",
          category: "exercise_authorship"
        ) do |ra|
          ra.amount = 10
        end
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
