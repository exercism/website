module Contributing
  class DashboardController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index]

    def show; end
  end
end
