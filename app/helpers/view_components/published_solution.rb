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
          exercise: solution.exercise,
          exercise_title: solution.exercise.title,
          track_title: solution.track.title,
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
