class Exercism::Routes
  def self.method_missing(name, *args)
    routes.send(name, *args)
  end

  def self.respond_to_missing?(name, include_all = false)
    routes.respond_to?(name, include_all)
  end

  def self.track_exercise_iteration_path(track, exercise, iteration)
    Exercism::Routes.track_exercise_iterations_path(track, exercise, idx: iteration.idx)
  end

  def self.private_solution_path(solution)
    [
      "tracks",
      solution.track.slug,
      "exercises",
      solution.exercise.slug
    ].join("/")
  end

  def self.private_solution_url(solution)
    [
      host,
      private_solution_path(solution)
    ].join("/")
  end

  def self.published_solution_url(solution)
    Exercism::Routes.track_exercise_community_solution_path(
      solution.track.slug,
      solution.exercise.slug,
      solution.user.handle
    )
  end

  def self.routes
    Rails.application.routes.url_helpers
  end

  def self.host
    Rails.application.routes.default_url_options[:host]
  end
end
