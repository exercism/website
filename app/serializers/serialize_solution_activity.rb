class SerializeSolutionActivity
  include Mandate

  initialize_with :solution

  def call
    {
      solution: {
        status: solution.status,
        mentoring_status: solution.mentoring_status,
        num_mentor_comments: mentor_comments[:count],
        unread_mentor_comments: mentor_comments[:unread],
        unsubmitted_code: false # TODO
      },
      exercise: {
        title: exercise.title,
        icon_name: exercise.icon_name
      },
      activities: activities_data,
      latest_iteration: latest_iteration_data,
      links: {
        exercise_url: Exercism::Routes.track_exercise_path(solution.track, exercise),
        editor_url: Exercism::Routes.edit_track_exercise_path(solution.track, exercise)
      }
    }
  end

  private
  memoize
  def exercise
    solution.exercise
  end

  memoize
  def mentor_comments
    discussion = solution.mentor_discussions.last
    return { count: 0, unread: false } unless discussion

    counts = discussion.posts.group(:seen_by_student).count

    {
      count: counts.values.sum,
      unread: !!counts[false]&.positive?
    }
  end

  def activities_data
    solution.user_activities.order(id: :desc).limit(5).map(&:rendering_data)
  end

  def latest_iteration_data
    iteration = solution.iterations.last
    return nil unless iteration

    SerializeIteration.(iteration)
  end
end
