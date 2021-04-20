class Tracks::MentorRequestsController < ApplicationController
  before_action :disable_site_header!
  before_action :use_solution

  def new
    @first_time_on_track = true
    @first_time_mentoring = true

    # TODO: Change to "if %i[requested in_progress].include(@solution.mentoring_status)
    return redirect_to action: :show if @solution.mentor_requests.pending.exists?
  end

  def show
    @mentor_request = @solution.mentor_requests.last

    if @mentor_request.fulfilled?
      redirect_to track_exercise_mentor_discussion_path(@track, @exercise, @mentor_request.discussion)
    elsif @mentor_request.cancelled?
      # TODO: Handle cancelled requests
    end
  end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
