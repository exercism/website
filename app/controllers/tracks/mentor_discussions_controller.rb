class Tracks::MentorDiscussionsController < ApplicationController
  before_action :use_discussion
  before_action :disable_site_header!

  def show; end

  private
  def use_discussion
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
    @discussion = @solution.mentor_discussions.find_by!(uuid: params[:id])
  end
end
