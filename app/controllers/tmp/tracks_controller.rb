class Tmp::TracksController < ApplicationController
  def create
    Track.create!(slug: params[:track_slug], title: params[:track_title], repo_url: "http://github.com/exercism/#{params[:track_slug]}")

    redirect_to maintaining_iterations_path
  end
end
