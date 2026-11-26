class Admin::SubmissionsController < Admin::BaseController
  before_action :ensure_maintainer_admin!

  def index
    @submissions = Submission.order(created_at: :desc).limit(NUMBER_OF_SUBMISSIONS)
  end

  NUMBER_OF_SUBMISSIONS = 50
end
