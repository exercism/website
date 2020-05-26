class Iteration
  class Representation
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, ast)
        @iteration = Iteration.find_by_uuid!(iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @ast = ast
      end

      def call
        # Let's create a record for debugging and to give
        # us some basis of the next set of decisions etc.
        iteration_representation = Iteration::Representation.create!(
          iteration: iteration,
          ops_status: ops_status,
          ops_message: ops_message,
          ast: ast
        )

        return handle_ops_error! if iteration_representation.ops_errored?

        # Now we need to check to see if we already have an exercise
        # representation for this iteration and version
        exercise_representation = Exercise::Representation.create_or_find_by!(
          exercise: iteration.exercise,
          exercise_version: exercise_version,
          ast_digest: iteration_representation.ast_digest
        ) do |rep|
          rep.ast = ast
        end

        # Then all of the submethods here should
        # action within transaction setting the 
        # status to be an error if it fails.
        begin
          case
          when exercise_representation.approve?
            handle_approve!
          when exercise_representation.disapprove?
            handle_disapprove!
          else 
            handle_pending!
          end
        rescue
          iteration.analysis_exceptioned!
        end

      end
      attr_reader :iteration, :ops_status, :ops_message, :ast

      private

      def exercise_version
        git_track = iteration.track.repo
        git_exercise = git_track.exercise(iteration.git_slug, iteration.git_sha)
        git_exercise.version.to_i # to_i returns everything up to the dot
      end

      def handle_ops_error!
        iteration.representation_exceptioned!
      end

      def handle_approve!
        iteration.representation_approved!
      end

      def handle_disapprove!
        iteration.representation_disapproved!
      end

      def handle_pending!
        iteration.representation_inconclusive!
      end
    end
  end
end
