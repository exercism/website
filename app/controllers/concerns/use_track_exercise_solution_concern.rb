# This provides three methods, which are intended as before filters:
# - use_track!
# - use_exercise!
# - use_solution
#
# The first two result in a 404 if the record is missing. The third doesn't.
# Calling use_solution also calls use_exercise and use_track if they've not previously
# be called, etc.

module UseTrackExerciseSolutionConcern
  extend ActiveSupport::Concern
  extend Mandate::Memoize

  def use_track!
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)

    render_404 unless @track.accessible_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def use_exercise!
    use_track! unless @track

    @exercise = @track.exercises.find(params[:exercise_id]) if @track
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  private
  def use_solution
    use_exercise! unless @exercise

    @solution = Solution.for(current_user, @exercise) if @exercise
  end
end
