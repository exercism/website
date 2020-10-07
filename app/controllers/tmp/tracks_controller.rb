class Tmp::TracksController < ApplicationController
  def create
    Track.create!(slug: params[:track_slug], title: params[:track_title], repo_url: params[:repo_url])

    redirect_to maintaining_submissions_path
  end
end
