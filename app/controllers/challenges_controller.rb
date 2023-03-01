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

    @tracks = Track.where(id: @track_counts.keys).index_by(&:id)

    valid_slugs = []
    feb_tracks = %w[clojure elixir erlang fsharp haskell ocaml scala sml gleam]
    feb_exercises = %w[hamming collatz-conjecture robot-simulator yacht protein-translation]
    valid_slugs += feb_tracks.product(feb_exercises)

    march_tracks = %w[c cpp d nim go rust vlang zig]
    march_exercises = %w[linked-list simple-linked-list secret-handshake sieve binary-search]
    valid_slugs += march_tracks.product(march_exercises)

    taken_exercises = []
    @badge_progress_exercises = current_user.solutions.where('YEAR(solutions.published_at) = 2023').published.
      joins(:track).pluck('tracks.slug', 'exercises.slug').
      select do |track_slug, exercise_slug|
        # We only want to count an exercise done in the first langauge its done in
        next if taken_exercises.include?(exercise_slug)

        valid_slugs.include?([track_slug, exercise_slug]).tap do |valid|
          taken_exercises << exercise_slug if valid
        end
      end
  end
end
