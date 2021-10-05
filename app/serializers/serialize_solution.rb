class SerializeSolution
  include Mandate

  def initialize(solution, user_track: nil, has_notifications: nil)
    @solution = solution
    @user_track = user_track
    @has_notifications = has_notifications
  end

  def call
    {
      uuid: solution.uuid,
      private_url: Exercism::Routes.private_solution_url(solution),
      public_url: Exercism::Routes.published_solution_url(solution),
      status: solution.status,
      mentoring_status: solution.mentoring_status,
      has_notifications: has_notifications?,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      num_iterations: solution.num_iterations,
      num_loc: solution.num_loc,
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
  attr_reader :solution

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
