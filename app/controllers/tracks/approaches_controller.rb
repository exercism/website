class Tracks::ApproachesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution

  skip_before_action :authenticate_user!

  def index
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?

    # Use same logic as in exercise_header: !user_track.external? && !solution&.unlocked_help?

    @videos = CommunityVideo.approved.for_exercise(@exercise)
    @introduction = introduction
    @links = links
  end

  def show
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?

    # Use same logic as in exercise_header: !user_track.external? && !solution&.unlocked_help?

    # TODO: - ERIK - data comes here
    @approach = OpenStruct.new(
      author: OpenStruct.new(
        avatar_url: "https://avatars.githubusercontent.com/u/135246?v=4",
        handle: "ErikSchierboom",
        name: "Erik Schierboom",
        formatted_reputation: 999
      ),
      content_html: "<h1>Hello</h1>",
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

  def introduction
    # TODO: introduce model for approach introduction
    {
      html: Markdown::Parse.(@exercise.approaches_introduction),
      avatar_urls: introduction_avatar_urls,
      num_authors: @exercise.approach_introduction_authors.count,
      num_contributors: @exercise.approach_introduction_contributors.count,
      updated_at: @exercise.approaches_introduction_last_modified_at,
      links: {
        new: "https://github.com/exercism/#{@track.slug}/new/main/exercises/#{@exercise.git_type}/#{@exercise.slug}/.approaches/introduction.md?filename=introduction.md",
        edit: "https://github.com/exercism/#{@track.slug}/edit/main/exercises/#{@exercise.git_type}/#{@exercise.slug}/.approaches/introduction.md"
      }
    }
  end

  def introduction_avatar_urls
    avatar_urls = proc { |users, limit| users.order("RAND()").limit(limit).select(:avatar_url).to_a.map(&:avatar_url) }

    target = 3
    urls = avatar_urls.(@exercise.approach_introduction_authors, target)
    if urls.size < 3 && @exercise.approach_introduction_contributors.count.positive?
      urls += avatar_urls.(@exercise.approach_introduction_contributors, target - urls.size)
    end
    urls.compact
  end

  def links
    {
      video: {
        lookup: Exercism::Routes.lookup_api_community_videos_path,
        create: Exercism::Routes.api_community_videos_path
      }
    }
  end
end
