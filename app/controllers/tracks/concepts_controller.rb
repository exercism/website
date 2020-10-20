class Tracks::ConceptsController < ApplicationController
  before_action :use_track
  before_action :use_concepts, only: :index
  before_action :use_concept, only: %i[show start complete]

  allow_unauthenticated! :index, :show

  def authenticated_index
    if current_user.joined_track?(@track)
      @concept_map_data = Track::DetermineConceptMapLayout.(@track).merge(
        status: UserTrack::GenerateConceptStatusMapping.(@user_track)
      )
      render action: "index/joined"
    else
      render action: "index/unjoined"
    end
  end

  def external_index; end

  def authenticated_show
    # TODO: We don't want this here really.
    # Move it onto the concept eventually
    @concept_exercise = ConceptExercise.that_teaches(@concept)

    if !current_user.joined_track?(@track)
      render action: "show/unjoined"
    elsif @user_track.learnt_concept?(@concept)
      render action: "show/learnt"
    elsif @user_track.concept_available?(@concept)
      render action: "show/available"
    else
      render action: "show/locked"
    end
  end

  def external_show; end

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
