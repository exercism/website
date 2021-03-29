module ViewComponents
  class PublishedSolution < ViewComponent
    extend Mandate::Memoize

    def initialize(solution)
      super()

      @solution = solution
    end

    def to_s
      ApplicationController.render "components/published_solution",
        locals: {
          user: solution.user,
          exercise: solution.exercise,
          track: solution.track,
          published_at: solution.published_at,
          num_stars: solution.num_stars,
          num_comments: solution.num_comments,
          num_lines: solution.num_loc,
          snippet: solution.snippet,
          highlightjs_language: "csharp" # TODO
        },
        layout: false
    end

    private
    attr_reader :solution
  end
end
