class ChallengesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show implementation_status]
  before_action :use_challenge_id!, except: %i[implementation_status track_implementation_status]
  before_action :use_track!, only: [:track_implementation_status]

  def show
    if user_signed_in? && User::Challenge.where(user: current_user, challenge_id: @challenge_id).exists?
      send("load_data_for_#{@challenge_id}")
      render action: @challenge_id
    else
      render action: "external"
    end
  end

  def start
    begin
      current_user.challenges.create!(challenge_id: @challenge_id)
    rescue ActiveRecord::RecordNotUnique
      # Catch double clicks
    end

    redirect_to action: :show
  end

  def implementation_status
    @featured_exercises = User::Challenges::FeaturedExercisesProgress48In24::EXERCISES
    @tracks = Track.active.order(:title)
    @track_exercises_status = User::Challenges::FeaturedExercisesImplementationStatus48In24.(@featured_exercises, @tracks)
  end

  def track_implementation_status
    @featured_exercises = User::Challenges::FeaturedExercisesProgress48In24::EXERCISES
    @exercise_status = User::Challenges::FeaturedExercisesImplementationStatus48In24.(@featured_exercises, [@track])[@track.slug]
  end

  private
  def use_challenge_id!
    @challenge_id = params[:id]
    redirect_to root_path unless User::Challenge::CHALLENGES.include?(@challenge_id)
  end

  def use_track!
    @track = Track.for!(params[:track_slug])
  end

  # Doing this in Ruby is *much* quicker than in SQL
  def load_data_for_12in23 # rubocop:disable Naming/VariableNumber
    # This gives us an array of tuples.
    iterated_exercise_ids = current_user.solutions.where('last_iterated_at > ?', Date.new(2022, 12, 31)).pluck(:exercise_id)

    # This gives us { exercise_id => [exercise_id, track_id, exercise_slug] }
    iterated_track_ids = Exercise.where(id: iterated_exercise_ids).where.not(slug: 'hello-world').pluck(:track_id)

    @track_counts = iterated_track_ids.
      tally. # This gives us {track_id => count}
      sort_by(&:second).reverse. # Order by highest count first
      to_h # Then back to {track_id => count}

    @tracks = Track.includes(:concepts).where(id: @track_counts.keys).index_by(&:id)
    @badge_progress_exercises = User::Challenges::FeaturedExercisesProgress12In23.(current_user)
    @badge_progress_exercise_earned_count = @badge_progress_exercises.count { |progress| progress[:earned_for].present? }
    @badge_progress_exercise_count = User::Challenges::FeaturedExercisesProgress12In23.num_featured_exercises
  end

  def load_data_for_48in24 # rubocop:disable Naming/VariableNumber
    @exercises = User::Challenges::FeaturedExercisesProgress48In24.(current_user)
  end
end
