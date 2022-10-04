class Tracks::ApproachesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution

  skip_before_action :authenticate_user!

  def index
    @videos = CommunityVideo.approved.for_exercise(@exercise)
    @introduction_html = Markdown::Parse.(@exercise.approaches_introduction)
    @introduction_authors = @exercise.approach_introduction_authors.order("RAND()").limit(3).select(:avatar_url).to_a.map(&:avatar_url)
    @num_introduction_authors = @exercise.approach_introduction_authors.count
  end

  def show
    # TODO: - ERIK - data comes here
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

  def tooltip_locked = render_template_as_json

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
  end
end
