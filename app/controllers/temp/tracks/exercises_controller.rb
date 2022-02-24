module Temp
  class Tracks::ExercisesController < ApplicationController
    skip_before_action :verify_authenticity_token

    before_action :use_track
    before_action :use_exercise

    private
    def use_track
      @track = Track.find(params[:track_id])
      @user_track = UserTrack.for(current_user, @track)

      render_404 unless @track.accessible_by?(current_user)
    end

    def use_exercise
      @exercise = @track.exercises.find(params[:id])
    end
  end
end
