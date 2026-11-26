class Admin::TracksController < Admin::BaseController
  before_action :ensure_maintainer_admin!
  before_action :use_recent_tracks

  # A track's slug is the name of its repo in the exercism org.
  SLUG_FORMAT = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
  NUM_RECENT_TRACKS = 5

  def new; end

  def create
    @slug = params[:slug].to_s.strip.downcase

    if @slug.blank?
      @error = "Enter the slug of the track to add."
    elsif !SLUG_FORMAT.match?(@slug)
      @error = "A slug can only contain lowercase letters, numbers and single hyphens, such as \"common-lisp\"."
    elsif (@existing_track = Track.find_by(slug: @slug))
      @error = "There is already a track with the slug \"#{@slug}\"."
    end

    return render :new, status: :unprocessable_entity if @error

    Track::Create.defer(@slug)
    redirect_to new_admin_track_path, notice: "The \"#{@slug}\" track has been queued to be added. " \
                                              "It will appear below once it has been created, usually within a few minutes."
  end

  private
  def use_recent_tracks
    @recent_tracks = Track.order(id: :desc).limit(NUM_RECENT_TRACKS)
  end
end
