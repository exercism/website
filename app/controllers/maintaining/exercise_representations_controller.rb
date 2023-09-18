class Maintaining::ExerciseRepresentationsController < Maintaining::BaseController
  def index
    @representations = Exercise::Representation.joins(exercise: :track).
      order("tracks.title, exercises.title")
  end

  def edit
    @representation = Exercise::Representation.find(params[:id])
  end

  def update
    @representation = Exercise::Representation.find(params[:id])
    @representation.update(
      feedback_markdown: params[:exercise_representation][:feedback_markdown],
      feedback_type: params[:exercise_representation][:feedback_type],
      feedback_author: current_user
    )
    redirect_to action: :index
  end
end
