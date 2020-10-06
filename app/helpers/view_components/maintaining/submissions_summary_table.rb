module ViewComponents
  module Maintaining
    class SubmissionsSummaryTable < ViewComponent
      initialize_with :submissions

      def to_s
        react_component("maintaining-submissions-summary-table", {
                          submissions: submissions.map(&:serialized)
                        })
      end
    end
  end
end
