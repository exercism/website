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
    Exercism::Routes.track_exercise_path(solution.track, solution.exercise)
  end

  def self.private_solution_url(solution)
    Exercism::Routes.track_exercise_url(solution.track, solution.exercise)
  end

  def self.published_solution_path(solution, **kwargs)
    published_solution_url(solution, **kwargs.merge(only_path: true))
  end

  def self.published_solution_url(solution, **kwargs)
    Exercism::Routes.track_exercise_solution_url(
      solution.track.slug,
      solution.exercise.slug,
      solution.user.handle,
      **kwargs
    )
  end

  def self.solving_exercises_locally_path
    Exercism::Routes.doc_path('using', 'solving-exercises/working-locally')
  end

  def self.routes
    Rails.application.routes.url_helpers
  end

  def self.host
    Rails.application.routes.default_url_options[:host]
  end
end
