class Tracks::MentoringRequestsController < ApplicationController
  before_action :use_solution

  def create
    Solution::MentorRequest::Create.(
      @solution,
      :code_review,
      params[:comment]
    )
    redirect_to track_exercise_mentoring_index_path(@track, @exercise)
  end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
