module ReactComponents
  module Maintaining
    class SubmissionsSummaryTable < ReactComponent
      initialize_with :submissions

      def to_s
        super(
          "maintaining-submissions-summary-table",
          {
            submissions: submissions.includes(:solution).
              map { |s| SerializeSubmissionForTable.(s) }
          }
        )
      end

      class SerializeSubmissionForTable
        include Mandate

        initialize_with :submission

        def call
          return unless submission

          solution_uuid = submission.solution.uuid

          {
            id: submission.uuid,
            track: submission.track.title,
            exercise: submission.exercise.title,
            tests_status: tests_data,
            representation_status: representer_data,
            analysis_status: analyzer_data,
            links: {
              cancel: Exercism::Routes.cancel_api_solution_submission_test_run_url(solution_uuid, submission),
              submit: Exercism::Routes.api_solution_iterations_url(solution_uuid, submission_id: submission.uuid),
              test_run: Exercism::Routes.api_solution_submission_test_run_url(solution_uuid, submission.uuid),
              initial_files: Exercism::Routes.api_solution_initial_files_url(solution_uuid)
            }
          }
        end

        def tests_data
          data = submission.tests_status
          if submission.tests_errored? || submission.tests_exceptioned?
            begin
              job = Exercism::ToolingJob.find(submission.test_run.tooling_job_id)
              data = append_exception_data(data, job)
            rescue StandardError
              # Silently ignore missing tooling job data
            end
          end
          data
        end

        def representer_data
          data = submission.representation_status
          if submission.representation_exceptioned?
            begin
              job = Exercism::ToolingJob.find(submission.submission_representation.tooling_job_id)
              data = append_exception_data(data, job)
            rescue StandardError
              # Silently ignore missing tooling job data
            end
          end
          data
        end

        def analyzer_data
          data = submission.analysis_status
          if submission.analysis_exceptioned?
            begin
              job = Exercism::ToolingJob.new(submission.analysis.tooling_job_id, {})
              data = append_exception_data(data, job)
            rescue StandardError
              # Silently ignore missing tooling job data
            end
          elsif submission.analysis
            data += "\n\n#{submission.analysis.send(:data)}"
          end
          data
        end

        def append_exception_data(data, job)
          stdout = job.stdout
          stderr = job.stderr
          data += "\n\nMetadata:\n------\n#{job.metadata}"
          data += "\n\nSTDOUT:\n------\n#{stdout}" if stdout.present?
          data += "\n\nSTDERR:\n------\n#{stderr}" if stderr.present?
          data
        end
      end
    end
  end
end
