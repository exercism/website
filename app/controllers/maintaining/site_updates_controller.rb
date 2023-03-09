class Maintaining::SiteUpdatesController < ApplicationController
  def index
    @updates = SiteUpdate.sorted
    @updates = @updates.for_track(Track.find(params[:track_slug])) if params[:track_slug].present?
    @updates = @updates.page(params[:page]).per(30)
  end

  def new
    @update = SiteUpdates::ArbitaryUpdate.new
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
end
