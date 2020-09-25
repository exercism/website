class Exercism::Routes
  def self.method_missing(name, *args)
    routes.send(name, *args)
  end

  def self.respond_to_missing?(name, include_all = false)
    routes.respond_to?(name, include_all)
  end

  def self.personal_solution_url(solution)
    [
      host,
      "tracks",
      solution.track.slug,
      "exercises",
      solution.exercise.slug
    ].join("/")
  end

  # TODO: Just ping this back to the routes file
  # once mentoring is added
  def self.mentor_solution_url(solution)
    [
      host,
      "mentoring",
      "solutions",
      solution.mentor_uuid
    ].join("/")
  end

  def self.routes
    Rails.application.routes.url_helpers
  end

  def self.host
    Rails.application.routes.default_url_options[:host]
  end
end
