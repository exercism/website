class Tracks::ConceptsController < ApplicationController
  before_action :use_track
  before_action :use_concepts, only: :index
  before_action :use_concept, only: %i[show start complete]

  allow_unauthenticated! :index, :show

  def authenticated_index
    if current_user.joined_track?(@track)
      render action: "index/joined"
    else
      render action: "index/unjoined"
    end
  end

  def external_index; end

  def authenticated_show
    if current_user.joined_track?(@track)
      @solution = Solution.for(current_user, @exercise)

      render action: "show/joined"
    else
      render action: "show/unjoined"
    end
  end

  def external_show; end

  def start
    solution = Solution::Create.(@user_track, @exercise)
    redirect_to edit_solution_path(solution.uuid)
  end

  def complete
    ConceptExercise::Complete.(@exercise)
    solution = Solution.for(current_user, @exercise)
    solution.complete!
    redirect_to action: :show
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
    @exercise = ConceptExercise.that_teaches!(@concept)
  end
end
