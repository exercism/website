class SerializeSolution
  include Mandate

  initialize_with :solution, user_track: nil, has_notifications: nil

  def call
    {
      uuid: solution.uuid,
      private_url: Exercism::Routes.private_solution_url(solution),
      public_url: Exercism::Routes.published_solution_url(solution),
      status: solution.status,
      mentoring_status: solution.mentoring_status,
      published_iteration_head_tests_status: solution.published_iteration_head_tests_status,
      has_notifications: has_notifications?,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      num_iterations: solution.num_iterations,
      num_loc: solution.num_loc.presence, # Currently this column is not-null in production
      is_out_of_date: solution.out_of_date?,

      published_at: solution.published_at&.iso8601,
      completed_at: solution.completed_at&.iso8601,
      updated_at: solution.updated_at.iso8601,
      last_iterated_at: solution.last_iterated_at&.iso8601,

      # These are already guarded against n+1s in the wider serializer
      exercise: {
        slug: exercise.slug,
        title: exercise.title,
        icon_url: exercise.icon_url
      },
      track: {
        slug: solution.track.slug,
        title: solution.track.title,
        icon_url: solution.track.icon_url
      }
    }
  end

  private
  def has_notifications?
    return @has_notifications unless @has_notifications.nil?

    user_track.exercise_has_notifications?(exercise)
  end

  memoize
  def exercise
    solution.exercise
  end

  memoize
  def user_track
    @user_track || UserTrack.for(solution.user, solution.track)
  end
end
