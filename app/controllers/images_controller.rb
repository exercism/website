class ImagesController < ApplicationController
  layout 'images'

  def solution
    @solution = Solution.for!(params[:user_handle], params[:track_slug], params[:exercise_slug])
  end
end
