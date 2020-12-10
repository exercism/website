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

        User::ReputationToken::ExerciseContributorship::Create.(contributorship)
      end
    end
  end
end
