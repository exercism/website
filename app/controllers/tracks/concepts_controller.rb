class Tracks::ConceptsController < ApplicationController
  before_action :use_track

  allow_unauthenticated! :index, :show

  def authenticated_index
    use_concepts

    if current_user.joined_track?(@track)
      render action: "index/joined"
    else
      render action: "index/unjoined"
    end
  end

  def external_index
    use_concepts
  end

  def authenticated_show
    use_concept

    if current_user.joined_track?(@track)
      render action: "show/joined"
    else
      render action: "show/unjoined"
    end
  end

  def external_show
    use_concept
  end

  private
  def use_track
    @track = Track.find(params[:track_id])
    @user_track = current_user&.user_track_for(@track)
  end

  def use_concepts
    @concepts = @track.concepts
  end

  def use_concept
    @concept = @track.concepts.find(params[:id])
  end
end
