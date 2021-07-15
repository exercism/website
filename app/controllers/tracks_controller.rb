class TracksController < ApplicationController
  before_action :use_track, except: :index
  skip_before_action :authenticate_user!, only: %i[index show]

  def index
    @tracks = Track::Search.(
      criteria: params[:criteria],
      tags: params[:tags],
      status: params[:status],
      user: current_user
    )

    @num_tracks = Track.count

    # TODO: (Optional) Change this to only select the fields needed for an icon
    @track_icon_urls = Track.active.order('rand()').limit(8).map(&:icon_url)
  end

  def show
    @user_track = UserTrack.for(current_user, @track)

    if @user_track.external?
      @showcase_exercises = @user_track.exercises.order("RAND()").limit(3).to_a
      render "tracks/show/unjoined"
    else
      # TODO: (Optional) Move this into a method somewhere else and add tests
      data = @user_track.solutions.
        where('completed_at > ?', Time.current.beginning_of_week - 8.weeks).
        group("week(completed_at)").count
      current_week = Date.current.cweek
      @last_8_weeks_counts = ((current_week - 8)...current_week).to_a.map { |w| (w % 53) + 1 }.map { |w| data.fetch(w, 0) }

      @recent_solutions = UserTrack::RetrieveRecentlyActiveSolutions.(@user_track)
      @updates = SiteUpdate.published.for_track(@track).sorted.limit(10)

      render "tracks/show/joined"
    end
  end

  def join
    UserTrack::Create.(current_user, @track)
    redirect_to action: :show
  end

  private
  def use_track
    @track = Track.find(params[:id])
  end
end
