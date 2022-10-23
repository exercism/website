class Community::StoriesController < ApplicationController
  skip_before_action :authenticate_user!

  # TODO: add index page
  def show
    @story = CommunityStory.find(params[:id])
    @other_stories = CommunityStory.includes(:interviewee).ordered_by_recency.first(3)
  end
end
