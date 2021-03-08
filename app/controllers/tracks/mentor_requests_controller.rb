class Tracks::MentorRequestsController < ApplicationController
  before_action :disable_site_header!
  before_action :use_solution

  def new
    @first_time_on_track = true
    @first_time_mentoring = true
  end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
