class API::TracksSerializer
  include Rails.application.routes.url_helpers
  include Mandate

  def initialize(tracks, user = nil)
    @tracks = tracks
    @user = user
  end

  def to_hash
    {
      tracks: tracks.map do |track|
        data_for_track(track).merge(user_data_for_track(track))
      end
    }
  end

  private
  attr_reader :tracks, :user

  def data_for_track(track)
    {
      id: track.id,
      title: track.title,
      num_concept_exercises: concept_exercise_counts[track.id].to_i,
      num_practice_exercises: practice_exercise_counts[track.id].to_i,
      web_url: routes.track_url(track),

      # TODO: Set all three of these
      icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
      is_new: true,
      tags: ["OOP", "Web Dev"]
    }
  end

  def user_data_for_track(track)
    return {} unless user

    {
      is_joined: joined_track_ids.include?(track.id),
      num_completed_concept_exercises: completed_concept_exercise_counts[track.id].to_i,
      num_completed_practice_exercises: completed_practice_exercise_counts[track.id].to_i
    }
  end

  memoize
  def routes
    Rails.application.routes.url_helpers
  end

  memoize
  def concept_exercise_counts
    ConceptExercise.
      where(track: tracks).
      group(:track_id).
      count
  end

  memoize
  def practice_exercise_counts
    PracticeExercise.
      where(track: tracks).
      group(:track_id).
      count
  end

  memoize
  def joined_track_ids
    UserTrack.
      where(user: user).
      where(track: tracks).
      map(&:track_id)
  end

  memoize
  def completed_concept_exercise_counts
    # TODO: This is currently exercises started. Once we've added
    # the completed flags to the db we should change it to completed
    ConceptSolution.
      joins(:exercise).
      where(user: user).
      where('exercises.track_id': tracks).
      group('exercises.track_id').
      count
  end

  memoize
  def completed_practice_exercise_counts
    # TODO: This is currently exercises started. Once we've added
    # the completed flags to the db we should change it to completed
    PracticeSolution.
      joins(:exercise).
      where(user: user).
      where('exercises.track_id': tracks).
      group('exercises.track_id').
      count
  end
end
