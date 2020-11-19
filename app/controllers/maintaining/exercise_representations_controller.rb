class Maintaining::ExerciseRepresentationsController < ApplicationController
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
      feedback_author: User.first
    )
    redirect_to action: :index
  end
end
