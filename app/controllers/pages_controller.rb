class PagesController < ApplicationController
  def index
    # solution = Solution.first
    # SubmissionsChannel.broadcast!(solution)
  end

  def health_check
    render json: { ruok: true }
  end
end
