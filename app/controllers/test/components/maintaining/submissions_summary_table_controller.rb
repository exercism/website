class Test::Components::Maintaining::SubmissionsSummaryTableController < Test::BaseController
  def index
    @submissions = Submission.order(created_at: :desc).limit(50)
  end
end
