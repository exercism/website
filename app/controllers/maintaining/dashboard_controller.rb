module Maintaining
  class DashboardController < ApplicationController
    def show
      @tracks = Track.order('title ASC')
    end
  end
end
