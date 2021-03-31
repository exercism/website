class Tracks::ConceptsController < ApplicationController
  before_action :use_track
  before_action :use_concepts, only: :index
  before_action :use_concept, only: %i[show tooltip start complete]

  skip_before_action :authenticate_user!, only: %i[index show tooltip]

  def index
    @concept_map_data = Track::DetermineConceptMapLayout.(@track)

    @concept_map_data[:status] =
      UserTrack::GenerateConceptStatusMapping.(@user_track)

    @concept_map_data[:exercise_statuses] =
      UserTrack::GenerateExerciseStatusMapping.(@track, @user_track)

    @num_concepts = @track.concepts.count
    @user_track ? @num_completed = @user_track.learnt_concepts.count : @num_completed = 0
  end

  def show
    @concept_exercises = @concept.concept_exercises
    @practice_exercises = @concept.practice_exercises
  end

  def tooltip
    @exercises = @concept.concept_exercises + @concept.practice_exercises
    @num_completed_exercises = @user_track.num_completed_exercises_for_concept(@concept)
    @locked = !@user_track.concept_unlocked?(@concept)
    @learnt = @user_track.concept_learnt?(@concept)
    @mastered = @user_track.concept_mastered?(@concept)
    @prerequisite_names = Track::Concept.joins(:unlocked_exercises).
      where('exercise_prerequisites.exercise_id': @concept.concept_exercises).
      pluck(:name)

    render_template_as_json
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track, external_if_missing: true)
  end

  def use_concepts
    @concepts = @track.concepts
  end

  def use_concept
    @concept = @track.concepts.find(params[:id])
  end
end
