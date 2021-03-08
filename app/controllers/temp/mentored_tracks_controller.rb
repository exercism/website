module Temp
  class MentoredTracksController < ApplicationController
    before_action :authenticate_user!

    def show
      tracks = ::Solution::MentorRequest::RetrieveTracks.(current_user)

      render json: { mentored_tracks: tracks }
    end
  end
end
