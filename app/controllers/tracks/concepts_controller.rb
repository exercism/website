class Tracks::ConceptsController < ApplicationController
  before_action :use_track
  before_action :use_concepts, only: :index
  before_action :use_concept, only: %i[show tooltip start complete]

  skip_before_action :authenticate_user!, only: %i[index show tooltip]

  def index
    @concept_map_data = Track::DetermineConceptMapLayout.(@user_track)

    @concept_map_data[:status] =
      UserTrack::GenerateConceptStatusMapping.(@user_track)

    @concept_map_data[:exercises_data] =
      UserTrack::GenerateExerciseStatusMapping.(@user_track)

    @num_concepts = @track.concepts.count
    @user_track ? @num_completed = @user_track.num_concepts_learnt : @num_completed = 0
  end

  def show
    @concept_exercises = @user_track.concept_exercises_for(concept: @concept)
    @practice_exercises = @user_track.practice_exercises_for(concept: @concept)

    if current_user
      @solutions = current_user.solutions.where(exercise_id: @concept_exercises.map(&:id) + @practice_exercises.map(&:id)).
        index_by(&:exercise_id)
    else
      @solutions = {}
    end
  end

  def tooltip
    @exercises = @user_track.concept_exercises_for(concept: @concept) + @user_track.practice_exercises_for(concept: @concept)
    @num_completed_exercises = @user_track.num_completed_exercises_for_concept(@concept)
    @locked = !@user_track.concept_unlocked?(@concept)
    @learnt = @user_track.concept_learnt?(@concept)
    @mastered = @user_track.concept_mastered?(@concept)
    @prerequisite_names = Concept.joins(:unlocked_exercises).
      where('exercise_prerequisites.exercise_id': @user_track.concept_exercises_for(concept: @concept)).
      pluck(:name)

    render_template_as_json
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
  end

  def use_concepts
    @concepts = @track.concepts
  end

  def use_concept
    @concept = @track.concepts.find(params[:id])
  end
end
