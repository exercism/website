class Test::Components::Common::SiteUpdatesListController < Test::BaseController
  def show
    @updates = SiteUpdate.all
    @icon = (params[:icon] || "update").to_sym
  end
end
