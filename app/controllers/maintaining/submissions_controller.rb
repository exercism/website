class Maintaining::SubmissionsController < ApplicationController
  def index
    @submissions = Submission.order(created_at: :desc).take(NUMBER_OF_SUBMISSIONS)
  end

  NUMBER_OF_SUBMISSIONS = 50
end
