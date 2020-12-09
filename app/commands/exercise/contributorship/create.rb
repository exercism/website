class Exercise
  class Contributorship
    class Create
      include Mandate

      initialize_with :exercise, :contributor

      def call
        contributorship = exercise.contributorships.create!(contributor: contributor)
        User::ReputationAcquisition.find_or_create_by!(
          user: contributor,
          reason_object: contributorship,
          reason: "exercise_contributorship",
          category: "exercise_contributorship"
        )
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end
  end
end
