class Mentor::Request::RetrieveExercises
  include Mandate

  initialize_with :mentor, :track_slug

  def call
    # TODO: (Optional) Cache this using track.updated_at
    # TODO: (Optional) Set track.updated_at to be touched when any exercises changes

    # Then add the order and enumerate here
    # TODO: (Optional) do we want to exclude wip exercises or only list the
    # exercises that have a mentoring request?
    track.exercises.order(title: :asc).map do |exercise|
      {
        slug: exercise.slug,
        title: exercise.title,
        icon_url: exercise.icon_url,
        count: request_counts[exercise.id].to_i,
        completed_by_mentor: completed_by_mentor.include?(exercise.id)
      }
    end
  end

  memoize
  def track
    Track.find(track_slug)
  end

  memoize
  def completed_by_mentor
    mentor.solutions.
      completed.
      where(exercise: track.exercises).
      pluck(:exercise_id)
  end

  memoize
  def request_counts
    # Use the inner query for this
    Mentor::Request::Retrieve.(
      mentor:,
      track_slug: track.slug,
      sorted: false, paginated: false
    ).group(:exercise_id).count
  end
end
