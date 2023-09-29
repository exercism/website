class API::CommunitySolutionStarsController < API::BaseController
  before_action :use_solution

  def create
    @solution.stars.create_or_find_by!(user: current_user)

    render json: {
      star: {
        num_stars: @solution.num_stars,
        is_starred: @solution.starred_by?(current_user)
      }
    }
  end

  def destroy
    @solution.stars.where(user: current_user).destroy_all

    render json: {
      star: {
        num_stars: @solution.num_stars,
        is_starred: @solution.starred_by?(current_user)
      }
    }
  end

  private
  def use_solution
    @track = Track.find(params[:track_slug])
    @exercise = @track.exercises.find(params[:exercise_slug])
    user = User.find_by!(handle: params[:community_solution_handle])
    @solution = @exercise.solutions.published.find_by!(user_id: user.id)
  end
end
