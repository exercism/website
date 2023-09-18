class Maintaining::SiteUpdatesController < Maintaining::BaseController
  def index
    @updates = SiteUpdate.sorted
    @updates = @updates.for_track(Track.find(params[:track_slug])) if params[:track_slug].present?
    @updates = @updates.page(params[:page]).per(30)
  end

  def new
    @update = SiteUpdates::ArbitraryUpdate.new
    setup_new_form
  end

  def create
    create_params = site_update_params.merge(author: current_user, published_at: Time.current)
    @update = SiteUpdates::ArbitraryUpdate.new(create_params)

    if @update.save
      flash[:site_updates_notice] = "Site update was successfully created."
      redirect_to %i[maintaining site_updates]
    else
      setup_new_form
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @update = SiteUpdate.find(params[:id])
  end

  def update
    @update = SiteUpdate.find(params[:id])

    if @update.editable_by?(current_user)
      @update.update!(
        params.require(:site_update).permit(
          :title, :description_markdown, :pull_request_number
        ).merge(author: current_user)
      )
    end

    redirect_to action: :index
  end

  private
  def setup_new_form
    @tracks = current_user.admin? ? Track.all :
      Track.where(slug: Github::TeamMember.where(user_id: current_user.uid).pluck(:team_name)).order(:title)
  end

  # Whitelist allowed parameters
  def site_update_params
    params.require(:site_update).permit(:title, :description_markdown, :track_id, :pull_request_number)
  end
end
