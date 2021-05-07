module API
  class CommunitySolutionStarsController < BaseController
    before_action :use_solution

    def create
      @solution.stars.create_or_find_by!(user: current_user)
    end

    def destroy
      @solution.stars.where(user: current_user).destroy_all
    end

    private
    def use_solution
      @track = Track.find(params[:track_id])
      @exercise = @track.exercises.find(params[:exercise_id])
      user = User.find_by!(handle: params[:community_solution_id])
      @solution = @exercise.solutions.published.find_by!(user_id: user.id)
    end
  end
end
