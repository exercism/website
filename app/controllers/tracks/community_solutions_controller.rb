class Tracks::CommunitySolutionsController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution, except: [:show]
  before_action :use_exercise!, only: [:show]

  skip_before_action :authenticate_user!

  def index
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?

    # Use same logic as in exercise_header: !user_track.external? && !solution&.unlocked_help?

    @endpoint = Exercism::Routes.api_track_exercise_community_solutions_url(@track, @exercise)
    @unscoped_total = @exercise.num_published_solutions
  end

  def show
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?

    # Use same logic as in exercise_header: !user_track.external? && !solution&.unlocked_help?

    begin
      @solution = User.find_by!(handle: params[:id]).
        solutions.published.find_by!(exercise_id: @exercise.id)
    rescue ActiveRecord::RecordNotFound
      # Legacy solutions used uuids here
      @solution = Solution.published.find_by!(uuid: params[:id])
    end

    @author = @solution.user
    @comments = @solution.comments
    @own_solution = @author == @current_user

    # TODO: (Required) Real algorithm here
    os_ids = @exercise.solutions.published.
      where.not(id: @solution.id).
      where(published_iteration_head_tests_status: %i[not_queued queued passed]).
      limit(4). # Limit 1 more than we show so we can exclude the solution id after SQL
      pluck(:id)

    # We want to manually exclude (after SQL!) the solution id, and then just select 3
    (os_ids - [@solution.id])[0, 3]

    @other_solutions = Solution.where(id: os_ids).includes(*SerializeSolutions::NP1_INCLUDES + [:published_exercise_representation])
    @mentor_discussions = @solution.mentor_discussions.finished.not_negatively_rated.includes(:mentor)
    @exercise_representation = @solution.published_exercise_representation
    @approach = @solution.latest_published_iteration_submission&.approach

    UserTrack::ViewedCommunitySolution::Create.defer(current_user, @track, @solution) if user_signed_in?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def tooltip_locked = render_template_as_json
end
