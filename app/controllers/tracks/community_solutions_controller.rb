class Tracks::CommunitySolutionsController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution, except: [:show]
  before_action :use_exercise!, only: [:show]

  skip_before_action :authenticate_user!

  def index
    @solutions = Solution::SearchCommunitySolutions.(@exercise)
    @endpoint = Exercism::Routes.api_track_exercise_community_solutions_url(@track, @exercise)
    @unscoped_total = @exercise.num_published_solutions
  end

  def show
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
    @other_solutions = @exercise.solutions.published.
      where.not(id: @solution.id).
      where(published_iteration_head_tests_status: %i[not_queued queued passed]).
      limit(3)
    @mentor_discussions = @solution.mentor_discussions.
      finished.not_negatively_rated.includes(:mentor)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
