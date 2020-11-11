module ReactComponents
  module Maintaining
    class SubmissionsSummaryTable < ReactComponent
      initialize_with :submissions

      def to_s
        super(
          "maintaining-submissions-summary-table",
          {
            submissions: submissions.map(&:serialized)
          }
        )
      end
    end
  end
end
