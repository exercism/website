module API
  class Mentoring::RegistrationController < BaseController
    def create
      unless params[:accept_terms]
        # TODO: Make this a proper response
        return render json: {}, status: :bad_request
      end

      begin
        User::BecomeMentor.(current_user, params[:track_ids])
      rescue InvalidTrackSlugsError
        # TODO: Make this a proper response
        return render json: {}, status: :bad_request
      rescue MissingTracksError
        # TODO: Make this a proper response
        return render json: {}, status: :bad_request
      end

      render json: {}, status: :ok
    end
  end
end
