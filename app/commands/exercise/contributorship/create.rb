class Exercise
  class Contributorship
    class Create
      include Mandate

      initialize_with :exercise, :contributor

      def call
        begin
          contributorship = exercise.contributorships.create!(contributor:)
        rescue ActiveRecord::RecordNotUnique
          return nil
        end

        AwardReputationTokenJob.perform_later(
          contributor,
          :exercise_contribution,
          contributorship:
        )
      end
    end
  end
end
