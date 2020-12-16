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

        User::ReputationToken::ExerciseAuthorship::Create.(authorship)
      end
    end
  end
end
