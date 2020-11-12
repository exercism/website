class Test::Templates::ConceptTooltipsController < Test::BaseController
  def show
    @user_track = UserTrack.first
    @track = @user_track.track
    @concept = @track.concepts.first
  end
end
