class SerializeMentorQueue
  include Mandate

  initialize_with :queue

  def call
    {
      results: requests,
      meta: { current: page, total: queue.size }
    }
  end

  def page
    1
  end

  def requests
    queue.map do |request|
      data_for_request(request)
    end
  end

  private
  def data_for_request(request)
    {
      # TODO: Maybe expose a UUID instead?
      id: request.id,

      track_title: request.track_title,
      track_icon_url: request.track_icon_url,
      exercise_title: request.exercise_title,

      mentee_handle: request.user_handle,
      mentee_avatar_url: request.user_avatar_url,

      # TODO: Should this be requested_at?
      updated_at: request.created_at,

      # TODO: Add all these
      is_starred: true,
      have_mentored_previously: true,
      status: "First timer",
      tooltip_url: "#",

      # TODO: Rename this to web_url
      # TODO: Maybe expose a UUID instead?
      url: Exercism::Routes.mentor_request_url(request)
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
