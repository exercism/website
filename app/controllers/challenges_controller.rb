class ChallengesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :use_challenge_id!

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

  private
  def use_challenge_id!
    @challenge_id = params[:id]
    redirect_to root_path unless User::Challenge::CHALLENGES.include?(@challenge_id)
  end

  def load_data_for_12in23 # rubocop:disable Naming/VariableNumber
    start_date = Date.new(2022, 12, 31)

    # Doing this in Ruby is *much* quicker than in SQL
    # It gives us an array of tuples
    solutions = current_user.solutions.pluck(:exercise_id, :last_iterated_at)
    solutions.select! { |solution| solution.second && solution.second >= start_date }

    # This gives us { exercise_id => [exercise_id, track_id, exercise_slug] }
    exercise_mapping = Exercise.where(id: solutions.map(&:first)).pluck(:id, :track_id, :slug).
      index_by(&:first)

    # Map to [track_id, iterated_at, exercise_slug]
    basic_data = solutions.map do |tuple|
      exercise = exercise_mapping[tuple[0]]
      [exercise[1], tuple[1], exercise[2]]
    end

    @track_counts = basic_data.
      reject { |tuple| tuple.third == 'hello-world' }.
      map(&:first). # Just track_ids
      tally. # This gives us {track_id => count}
      sort_by(&:second).reverse # Order by highest count first
    to_h # Then back to {track_id => count}

    @tracks = Track.where(id: @track_counts.keys).index_by(&:id)
  end
end
