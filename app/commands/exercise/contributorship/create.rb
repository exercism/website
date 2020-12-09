class Exercise
  class Contributorship
    class Create
      include Mandate

      initialize_with :exercise, :contributor

      def call
        begin
          contributorship = exercise.contributorships.create!(contributor: contributor)
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        User::ReputationAcquisition.find_or_create_by!(
          user: contributor,
          reason_object: contributorship,
          reason: "exercise_contributorship",
          category: "exercise_contributorship"
        )
      end
    end
  end
end
