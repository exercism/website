class Tracks::ConceptsController < ApplicationController
  before_action :use_track
  before_action :use_concepts, only: :index
  before_action :use_concept, only: %i[show tooltip start complete]

  before_action :guard_practice_mode!, only: [:index]
  before_action :guard_course!, only: [:index]
  skip_before_action :authenticate_user!, only: %i[index show tooltip]
  before_action :cache_index_action!, only: %i[index]
  before_action :cache_show_action!, only: %i[show]

  def index
    @concept_map_data = Track::DetermineConceptMapLayout.(@user_track)

    @concept_map_data[:status] =
      UserTrack::GenerateConceptStatusMapping.(@user_track)

    @concept_map_data[:exercises_data] =
      UserTrack::GenerateExerciseStatusMapping.(@user_track)

    @user_track ? @num_completed = @user_track.num_concepts_learnt : @num_completed = 0
  end

  def show
    @concept_exercises = @user_track.concept_exercises_for_concept(@concept)
    @practice_exercises = @user_track.practice_exercises_for_concept(@concept)

    if current_user
      @solutions = current_user.solutions.where(exercise_id: @concept_exercises.map(&:id) + @practice_exercises.map(&:id)).
        index_by(&:exercise_id)
    else
      @solutions = {}
    end
  end

  def tooltip
    @exercises = @user_track.concept_exercises_for_concept(@concept) + @user_track.practice_exercises_for_concept(@concept)
    @num_completed_exercises = @user_track.num_completed_exercises_for_concept(@concept)
    @locked = !@user_track.concept_unlocked?(@concept)
    @learnt = @user_track.concept_learnt?(@concept)
    @mastered = @user_track.concept_mastered?(@concept)

    # TODO: This needs a test (this whole thing does!)
    @prerequisite_names = Concept.joins(:unlocked_exercises).
      where('exercise_prerequisites.exercise_id': @user_track.concept_exercises_for_concept(@concept)).
      pluck(:slug, :name).
      reject { |slug, _name| @user_track.concept_learnt?(slug) }.
      map(&:second)

    render_template_as_json
  end

  private
  # The concept map only changes when the track syncs, which purges it.
  # See Track::InvalidateCloudflareCache. The per-user status mappings that
  # this action also builds are empty for the signed-out visitors that get
  # cached, and cache_public_action! no-ops for everyone else.
  def cache_index_action! = cache_public_action!(edge_ttl: 1.day)

  # A concept page only changes when the concept syncs, which purges it.
  # See Concept::InvalidateCloudflareCache. The per-user data this action
  # builds is empty for the signed-out visitors that get cached, and
  # cache_public_action! no-ops for everyone else.
  def cache_show_action! = cache_public_action!(edge_ttl: 1.day)

  def use_track
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)

    render_404 unless @track.accessible_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def use_concepts
    @concepts = @track.concepts
  end

  def use_concept
    @concept = @track.concepts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def guard_practice_mode!
    return unless @user_track.practice_mode?

    redirect_to track_path(@track)
  end

  def guard_course!
    return if @user_track.course?

    redirect_to track_path(@track)
  end
end
