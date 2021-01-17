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
          num_stars: 10, # TODO
          num_comments: 2, # TODO
          num_lines: 9, # TODO
          snippet: snippet, # TODO
          highlightjs_language: "csharp" # TODO
        },
        layout: false
    end

    private
    attr_reader :solution

    def snippet
      '
public class Year
{
  public static bool IsLeap(int year)
  {
      if (year % 4 != 0) return false
      if (year % 100 == 0 && year % 400) return false
      return true;
  }
}
      '.strip
    end
  end
end
