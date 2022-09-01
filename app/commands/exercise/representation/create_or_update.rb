class Exercise
  class Representation
    class CreateOrUpdate
      include Mandate

      initialize_with :submission, :ast, :ast_digest, :mapping, :last_submitted_at

      def call
        representation = Exercise::Representation.find_create_or_find_by!(exercise:, ast_digest:) do |rep|
          rep.source_submission = submission
          rep.ast = ast
          rep.mapping = mapping
          rep.last_submitted_at = last_submitted_at
        end

        representation.update!(last_submitted_at:)
        Exercise::Representation::UpdateNumSubmissions.defer(representation)

        representation
      end

      delegate :exercise, to: :submission
    end
  end
end
