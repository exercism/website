class SerializeTracks
  include Mandate

  def initialize(tracks, user = nil)
    @tracks = tracks
    @user = user
  end

  def call
    sorted_tracks.map do |track|
      SerializeTrack.(
        track,
        user_tracks[track.id],
        # All of this is probably better manages off the usertracksummary
        num_concepts: concept_counts[track.id].to_i,
        num_learnt_concepts: learnt_concepts_counts[track.id].to_i,
        num_concept_exercises: concept_exercise_counts[track.id].to_i,
        num_practice_exercises: practice_exercise_counts[track.id].to_i,
        num_completed_concept_exercises: completed_concept_exercise_counts[track.id].to_i,
        num_completed_practice_exercises: completed_practice_exercise_counts[track.id].to_i
      )
    end
  end

  private
  attr_reader :tracks, :user

  def sorted_tracks
    tracks.sort_by do |track|
      "#{joined?(track) ? 0 : 1} | #{track.title.downcase}"
    end
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
  def user_tracks
    return [] unless user

    UserTrack.
      where(user: user).
      where(track: tracks).
      index_by(&:track_id)
  end

  memoize
  def learnt_concepts_counts
    return {} unless user

    UserTrack::LearntConcept.
      joins(:user_track).
      where('user_tracks.user_id': user.id).
      where('user_tracks.track_id': tracks).
      group('user_tracks.track_id').
      count
  end

  memoize
  def completed_concept_exercise_counts
    return {} unless user

    ConceptSolution.
      joins(:exercise).
      where(user: user).
      where.not(completed_at: nil).
      where('exercises.track_id': tracks).
      group('exercises.track_id').
      count
  end

  memoize
  def completed_practice_exercise_counts
    return {} unless user

    PracticeSolution.
      joins(:exercise).
      where(user: user).
      where.not(completed_at: nil).
      where('exercises.track_id': tracks).
      group('exercises.track_id').
      count
  end

  memoize
  def joined_track_ids
    return [] unless user

    UserTrack.where(user: user).pluck(:track_id)
  end

  def joined?(track)
    joined_track_ids.include?(track.id)
  end
end
