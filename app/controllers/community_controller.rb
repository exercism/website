class CommunityController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def show
    @title = 'From Homeless to Hero - The Story of Bobbi Towers'
    # rubocop:disable Layout/LineLength
    @description = 'Listen to the story of how Bobbi went from being on the streets, to getting back on their feet in the face of adversity.'
    # rubocop:enable Layout/LineLength
  end
end
