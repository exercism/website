# TODO: This is just a stub
module API
  class UserTracksController < BaseController
    def activate_practice_mode
      user_track = UserTrack.find(params[:id])
      render json: {
        user_track: {
          links: {
            self: Exercism::Routes.practice_mode_temp_user_track_url(user_track)
          }
        }
      }
    end
  end
end
