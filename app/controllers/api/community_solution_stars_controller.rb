class API::CommunitySolutionStarsController < API::BaseController
  before_action :use_solution

  def create
    Solution::Star::Create.(@solution, current_user)

    render json: {
      star: {
        num_stars: @solution.num_stars,
        is_starred: @solution.starred_by?(current_user)
      }
    }
  end

  def destroy
    Solution::Star::Destroy.(@solution, current_user)

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
