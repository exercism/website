module ViewComponents
  module Example
    class SubmissionsSummaryTable < ViewComponent
      initialize_with :solution

      def to_s
        react_component("example-submissions-summary-table", {
                          solution_id: solution.id,
                          submissions: solution.serialized_submissions
                        })
      end
    end
  end
end
