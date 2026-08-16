class Tracks::ApproachesController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_solution
  before_action :use_approach, only: :show
  before_action :guard_accessible!

  skip_before_action :authenticate_user!
  before_action :cache_public_page!, only: %i[index show]

  def index
    redirect_to track_exercise_dig_deeper_path(@track, @exercise)
  end

  def show
    @other_approaches = SerializeApproaches.(@exercise.approaches.where.not(id: @approach.id).random)
    @num_authors = @approach.authors.count
    @num_contributors = @approach.contributors.count
    @users = CombineAuthorsAndContributors.(@approach.authors, @approach.contributors).map do |user|
      SerializeAuthorOrContributor.(user)
    end

    UserTrack::ViewedExerciseApproach::Create.defer(current_user, @track, @approach) if user_signed_in?
  end

  private
  # Approaches only change when the track syncs, which purges them.
  # See Exercise::InvalidateCloudflareCache.
  def cache_public_page! = cache_public_action!(edge_ttl: 1.day)

  def use_solution
    @track = Track.find(params[:track_id])
    @user_track = UserTrack.for(current_user, @track)
    @exercise = @track.exercises.find(params[:exercise_id])
    @solution = Solution.for(current_user, @exercise)
    render_404 unless @track.accessible_by?(current_user)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def use_approach
    @approach = @exercise.approaches.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def guard_accessible!
    return redirect_to track_exercise_path(@track, @exercise) if @exercise.tutorial?
    return if @user_track.external? || @solution&.unlocked_help? || @solution&.iterated?

    redirect_to track_exercise_path(@track, @exercise)
  end
end
