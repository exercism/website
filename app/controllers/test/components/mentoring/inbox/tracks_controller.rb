class Test::Components::Mentoring::Inbox::TracksController < ApplicationController
  def index
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    results = [
      {
        id: 1,
        title: "Ruby",
        icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png"
      },
      {
        id: 2,
        title: "Go",
        icon_url: "https://assets.exercism.io/tracks/go-hex-white.png"
      }
    ]

    render json: results
  end
end
