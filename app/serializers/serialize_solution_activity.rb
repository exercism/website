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
      exercise: solution.exercise,
      activities: activities_data,
      latest_iteration: solution.iterations.last
    }
  end

  private
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
end
