class Community::StoriesController < ApplicationController
  skip_before_action :authenticate_user!

  # TODO: add index page
  def show
    @story = CommunityStory.find(params[:id])
  end
end
