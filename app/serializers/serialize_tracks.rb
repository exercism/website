class SerializeTracks
  include Mandate

  def initialize(tracks, user = nil)
    @tracks = tracks
    @user = user
  end

  def call
    {
      tracks: sorted_tracks.map do |track|
        data_for_track(track).merge(user_data_for_track(track))
      end
    }
  end

  private
  attr_reader :tracks, :user

  def sorted_tracks
    tracks.sort_by do |track|
      "#{joined?(track) ? 0 : 1} | #{track.title.downcase}"
    end
  end

  def data_for_track(track)
    {
      id: track.id,
      title: track.title,
      num_concepts: concept_counts[track.id].to_i,
      num_concept_exercises: concept_exercise_counts[track.id].to_i,
      num_practice_exercises: practice_exercise_counts[track.id].to_i,
      web_url: Exercism::Routes.track_url(track),
      icon_url: track.icon_url,

      # TODO: Set all three of these
      is_new: true,
      tags: track.tags.to_a
    }
  end

  def user_data_for_track(track)
    return {} unless user

    {
      is_joined: joined?(track),
      num_learnt_concepts: learnt_concepts_counts[track.id].to_i,
      num_completed_concept_exercises: completed_concept_exercise_counts[track.id].to_i,
      num_completed_practice_exercises: completed_practice_exercise_counts[track.id].to_i
    }
  end

  memoize
  def concept_counts
    Track::Concept.
      where(track: tracks).
      group(:track_id).
      count
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
  def learnt_concepts_counts
    UserTrack::LearntConcept.
      joins(:user_track).
      where('user_tracks.user_id': user.id).
      where('user_tracks.track_id': tracks).
      group('user_tracks.track_id').
      count
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

  def joined?(track)
    joined_track_ids.include?(track.id)
  end
end
