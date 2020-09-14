class Test::Components::Mentoring::MentorInboxes::TracksController < ApplicationController
  def index
    results = [
      {
        id: 1,
        title: "Ruby",
        iconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png"
      },
      {
        id: 2,
        title: "Go",
        iconUrl: "https://assets.exercism.io/tracks/go-hex-white.png"
      }
    ]

    render json: results
  end
end
