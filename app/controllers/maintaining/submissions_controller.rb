class Maintaining::SubmissionsController < Maintaining::BaseController
  def index
    @submissions = Submission.order(created_at: :desc).limit(NUMBER_OF_SUBMISSIONS)
  end

  NUMBER_OF_SUBMISSIONS = 50
end
