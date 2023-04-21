module Maintaining
  class DashboardController < Maintaining::BaseController
    def show
      @tracks = Track.order('title ASC')
    end
  end
end
