# TODO: This is just a stub
module API
  class UserTracksController < BaseController
    before_action :use_track

    def activate_practice_mode
      @user_track.update(practice_mode: true)

      render json: {
        user_track: {
          links: {
            self: track_url(@track)
          }
        }
      }
    end

    def reset
      user_track = UserTrack.find(params[:id])
      render json: {
        user_track: {
          links: {
            self: Exercism::Routes.reset_temp_user_track_url(user_track)
          }
        }
      }
    end

    def leave
      user_track = UserTrack.find(params[:id])
      render json: {
        user_track: {
          links: {
            self: Exercism::Routes.leave_temp_user_track_url(user_track)
          }
        }
      }
    end

    private
    def use_track
      @track = Track.find(params[:track_id])
      # TODO: Rescue and handle
      @user_track = UserTrack.for!(current_user, @track)
    end
  end
end
