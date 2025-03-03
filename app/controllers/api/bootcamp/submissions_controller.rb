class API::Bootcamp::SubmissionsController < API::Bootcamp::BaseController
  before_action :use_solution

  def create
    submission = Bootcamp::Submission::Create.(
      @solution,
      params[:submission][:code],
      params[:submission][:test_results].to_h,
      params[:submission][:readonly_ranges],
      params[:submission][:custom_functions]
    )
    render json: {
      submission: {
        uuid: submission.uuid
      }
    }, status: :created
  end
end
