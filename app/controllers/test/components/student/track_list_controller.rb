class Test::Components::Student::TrackListController < ApplicationController
  def show
    @data = API::TracksSerializer.new(Track.all, User.first)
  end
end
