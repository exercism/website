class API::Mentoring::RegistrationController < API::BaseController
  def create
    unless params[:accept_terms]
      # TODO: (Required) Make this a proper response
      return render json: {}, status: :bad_request
    end

    begin
      User::BecomeMentor.(current_user, params[:track_slugs])
    rescue InvalidTrackSlugsError
      # TODO: (Required) Make this a proper response
      return render json: {}, status: :bad_request
    rescue MissingTracksError
      # TODO: (Required) Make this a proper response
      return render json: {}, status: :bad_request
    end

    render json: {}, status: :ok
  end
end
