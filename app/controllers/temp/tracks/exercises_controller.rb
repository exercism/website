module Temp
  class Tracks::ExercisesController < ApplicationController
    skip_before_action :verify_authenticity_token

    before_action :use_track
    before_action :use_exercise

    def start
      Solution::Create.(current_user, @exercise)

      render json: {
        links: {
          edit: Exercism::Routes.edit_track_exercise_url(@track, @exercise)
        }
      }
    end

    private
    def use_track
      @track = Track.find(params[:track_id])
      @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
    end

    def use_exercise
      @exercise = @track.exercises.find(params[:id])
    end
  end
end
