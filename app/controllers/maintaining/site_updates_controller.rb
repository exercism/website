class Maintaining::SiteUpdatesController < ApplicationController
  def index
    @updates = SiteUpdate.order(published_at: :desc).page(params[:page]).per(20)
  end

  def edit
    @update = SiteUpdate.find(params[:id])
  end

  def update
    @update = SiteUpdate.find(params[:id])

    if @update.editable_by?(current_user)
      @update.update!(
        params.require(:site_update).permit(
          :title, :description, :pull_request_number
        ).merge(author: current_user)
      )
    end

    redirect_to action: :index
  end
end
