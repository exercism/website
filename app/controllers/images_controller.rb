class ImagesController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'images'

  def solution
    @solution = Solution.for!(params[:user_handle], params[:track_slug], params[:exercise_slug])
  end
end
