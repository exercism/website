class Test::Components::Student::TrackListController < ApplicationController
  def show
    @data = API::TracksSerializer.new(Track.all, User.first)
  end

  def tracks
    render json: API::TracksSerializer.new(Track.all, User.first).to_json
  end
end
