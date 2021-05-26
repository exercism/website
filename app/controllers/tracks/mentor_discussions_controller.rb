class Tracks::MentorDiscussionsController < ApplicationController
  before_action :use_solution
  before_action :use_discussion, only: :show
  before_action :disable_site_header!, only: :show

  def index; end

  def show; end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for!(current_user, @exercise)
  end

  def use_discussion
    @discussion = @solution.mentor_discussions.find_by!(uuid: params[:id])
  end
end
