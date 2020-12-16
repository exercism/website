class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # solution = Solution.first
    # SubmissionsChannel.broadcast!(solution)
  end

  def health_check
    render json: { ruok: true }
  end
end
