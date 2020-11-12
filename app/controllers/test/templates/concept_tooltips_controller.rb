class Test::Templates::ConceptTooltipsController < Test::BaseController
  def show
    @user_track = UserTrack.first
    @track = @user_track.track
    @concept = @track.concepts.find_by!(slug: "basics")
  end
end
