class Test::Components::Maintaining::SubmissionsSummaryTableController < Test::BaseController
  def index
    @submissions = Submission.order(created_at: :desc).take(50)
  end
end
