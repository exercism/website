class Tracks::DigDeeperController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution
  before_action :guard_accessible!, except: :tooltip_locked

  skip_before_action :authenticate_user!

  def show
    @videos = @exercise.community_videos.approved
    @approaches = @exercise.approaches
    @articles = @exercise.articles
    @introduction = introduction
    @links = links
  end

  def tooltip_locked = render_template_as_json

  private
  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
    render_404 unless @track.accessible_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def guard_accessible!
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?
    return if @user_track.external? || @solution&.unlocked_help? || @solution&.iterated?

    redirect_to track_exercise_path(@track, @exercise)
  end

  def introduction
    # TODO: introduce model for approach introduction
    {
      html: Markdown::Parse.(@exercise.approaches_introduction),
      users: introduction_users,
      num_authors: @exercise.approach_introduction_authors.count,
      num_contributors: @exercise.approach_introduction_contributors.count,
      updated_at: @exercise.approaches_introduction_last_modified_at,
      links: {
        edit: @exercise.approaches_introduction_edit_url
      }
    }
  end

  def introduction_users
    CombineAuthorsAndContributors.(@exercise.approach_introduction_authors, @exercise.approach_introduction_contributors).map do |user|
      SerializeAuthorOrContributor.(user)
    end
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
