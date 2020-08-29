class Iteration
  class Representation
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, ast)
        @iteration = Iteration.find_by!(uuid: iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @ast = ast
      end

      def call
        # Firstly, create a record for debugging and to give
        # us some basis of the next set of decisions etc.
        @iteration_representation = Iteration::Representation.create!(
          iteration: iteration,
          ops_status: ops_status,
          ops_message: ops_message,
          ast: ast
        )

        return handle_ops_error! if iteration_representation.ops_errored?

        # Now we need to check to see if we already have an exercise
        # representation for this iteration and version
        @exercise_representation = Exercise::Representation.create_or_find_by!(
          exercise: iteration.exercise,
          exercise_version: exercise_version,
          ast_digest: iteration_representation.ast_digest
        ) do |rep|
          # rep.source_iteration = iteration
          rep.ast = ast
          # rep.mapping = mapping
        end

        # Then all of the submethods here should
        # action within transaction setting the
        # status to be an error if it fails.
        begin
          if exercise_representation.approve?
            handle_approve!
          elsif exercise_representation.disapprove?
            handle_disapprove!
          else
            handle_pending!
          end
        rescue StandardError
          iteration.analysis_exceptioned!
        end

        iteration.broadcast!
      end
      attr_reader :iteration, :ops_status, :ops_message, :ast
      attr_reader :iteration_representation, :exercise_representation

      private
      def exercise_version
        iteration.exercise_version.to_i # to_i returns everything up to the dot
      end

      def handle_ops_error!
        iteration.representation_exceptioned!
      end

      def handle_approve!
        iteration.representation_approved!
        create_discussion_post!
      end

      def handle_disapprove!
        iteration.representation_disapproved!
        create_discussion_post!
      end

      def handle_pending!
        iteration.representation_inconclusive!
      end

      def create_discussion_post!
        return unless exercise_representation.has_feedback?

        Iteration::DiscussionPost::CreateFromRepresentation.(
          iteration,
          iteration_representation,
          exercise_representation
        )
      end
    end
  end
end
