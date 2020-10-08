class Tracks::ExercisesController < ApplicationController
  before_action :use_track
  before_action :use_exercise, only: %i[show start complete]

  allow_unauthenticated! :index, :show

  def authenticated_index
    use_practice_exercises

    if current_user.joined_track?(@track)
      render action: "index/joined"
    else
      render action: "index/unjoined"
    end
  end

  def external_index
    use_practice_exercises
  end

  def authenticated_show
    use_exercise
    @solution = Solution.for(current_user, @exercise)

    if current_user.joined_track?(@track)
      render action: "show/joined"
    else
      render action: "show/unjoined"
    end
  end

  def external_show
    use_exercise
  end

  def start
    solution = Solution::Create.(current_user, @exercise)
    redirect_to edit_solution_path(solution.uuid)
  end

  def complete
    ConceptExercise::Complete.(current_user, @exercise)
    redirect_to action: :show
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
  end

  def use_practice_exercises
    @practice_exercises = @track.practice_exercises
  end

  def use_exercise
    @exercise = @track.exercises.find(params[:id])
  end
end
