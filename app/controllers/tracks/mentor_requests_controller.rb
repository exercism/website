class Tracks::MentorRequestsController < ApplicationController
  before_action :disable_site_header!, except: [:no_slots_remaining]
  before_action :use_solution

  def new
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?

    @first_time_on_track = true
    @first_time_mentoring = true

    # TODO: (Optional) Change to "if %i[requested in_progress].include(@solution.mentoring_status)
    #
    return redirect_to action: :show if @solution.mentor_requests.pending.exists?
    return redirect_to action: :show if @solution.mentor_discussions.in_progress_for_student.exists?
    return redirect_to action: :no_slots_remaining unless @user_track.has_available_mentoring_slot?
  end

  def no_slots_remaining; end

  def show
    @mentor_request = @solution.mentor_requests.last

    if @mentor_request.fulfilled?
      redirect_to track_exercise_mentor_discussion_path(@track, @exercise, @mentor_request.discussion)
    elsif @mentor_request.cancelled?
      # TODO: (Required) Handle cancelled requests
    end
  end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
