class Tracks::ApproachesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution

  skip_before_action :authenticate_user!

  def index
    #  TODO: Erik - only approved
    @videos = CommunityVideo.approved.for_exercise(@exercise)
  end

  def show
    @approach = OpenStruct.new(
      author: OpenStruct.new(
        avatar_url: "https://avatars.githubusercontent.com/u/135246?v=4",
        handle: "Erik",
        formatted_reputation: 999
      ),
      title: "Utilising In-built Date Functions for Consistency",
      published_at: DateTime.now
    )
    @other_approaches = Array.new(3)
    @contributors = OpenStruct.new(
      num_authors: 3,
      num_contributors: 5,
      avatar_urls: Array.new(3).fill('https://avatars.githubusercontent.com/u/135246?v=4')
    )
  end

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
