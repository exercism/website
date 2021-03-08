module Temp
  class MentoredTracksController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!

    def update
      tracks = Track.where(slug: params[:track_slugs])

      current_user.mentored_tracks = tracks

      render json: { mentored_tracks: ::Solution::MentorRequest::RetrieveTracks.(current_user) }
    end

    def show
      tracks = ::Solution::MentorRequest::RetrieveTracks.(current_user)

      render json: { mentored_tracks: tracks }
    end
  end
end
