class Tracks::ExercisesController < ApplicationController
  before_action :use_track

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

    if current_user.joined_track?(@track)
      render action: "show/joined"
    else
      render action: "show/unjoined"
    end
  end

  def external_show
    use_exercise
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
