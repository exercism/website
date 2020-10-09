class Exercism::Routes
  def self.method_missing(name, *args)
    routes.send(name, *args)
  end

  def self.respond_to_missing?(name, include_all = false)
    routes.respond_to?(name, include_all)
  end

  def self.private_solution_url(solution)
    [
      host,
      "tracks",
      solution.track.slug,
      "exercises",
      solution.exercise.slug
    ].join("/")
  end

  def self.published_solution_url(solution)
    [
      host,
      "tracks",
      solution.track.slug,
      "exercises",
      solution.exercise.slug,
      "solutions",
      solution.user.handle
    ].join("/")
  end

  def self.routes
    Rails.application.routes.url_helpers
  end

  def self.host
    Rails.application.routes.default_url_options[:host]
  end
end
