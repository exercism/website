module API
  class ExercisesController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user
    before_action :use_track

    def index
      exercises = Exercise::Search.(
        @track,
        criteria: params[:criteria]
      )
      output = {
        exercises: SerializeExercises.(
          exercises,
          user_track: UserTrack.for(current_user, @track)
        )
      }

      if sideload?(:solutions)
        output[:solutions] = SerializeSolutions.(
          current_user.solutions.where(exercise_id: exercises)
        )
      end

      render json: output
    end

    private
    def use_track
      @track = Track.find(params[:track_id])
    end
  end
end
