class Exercise
  class Representation
    class Create
      include Mandate

      initialize_with :submission, :ast, :ast_digest, :mapping

      def call
        Exercise::Representation.create_or_find_by!(exercise:, ast_digest:) do |rep|
          rep.source_submission = submission
          rep.ast = ast
          rep.mapping = mapping
        end.tap do |rep| # rubocop:disable Style/MultilineBlockChain
          Exercise::Representation::UpdateNumSubmissions.defer(rep)
        end
      end

      delegate :exercise, to: :submission
    end
  end
end
