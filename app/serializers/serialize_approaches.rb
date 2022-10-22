class SerializeApproaches
  include Mandate

  initialize_with :approaches

  def call = approaches.map { |approach| SerializeApproach.(approach) }

  class SerializeApproach
    include Mandate

    initialize_with :approach

    def call
      {
        users: CombineAuthorsAndContributors.(approach.authors, approach.contributors).map do |user|
          SerializeAuthorOrContributor.(user)
        end,
        num_authors: approach.authors.count,
        num_contributors: approach.contributors.count,
        slug: approach.slug,
        title: approach.title,
        blurb: approach.blurb,
        snippet: approach.snippet,
        links: {
          self: Exercism::Routes.track_exercise_approach_path(approach.track, approach.exercise, approach)
        }
      }
    end
  end
end
