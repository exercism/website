module ViewComponents
  class PublishedSolution < ViewComponent
    extend Mandate::Memoize

    def initialize(solution)
      super

      @solution = solution
    end

    def to_s
      tag.div class: "c-published-solution" do
        header_tag + pre_tag + footer_tag
      end
    end

    private
    attr_reader :solution

    def header_tag
      tag.header do
        tag.div(class: "exercise") do
          exercise_icon(exercise, css_class: "exercise-icon") +
            tag.div(class: "info") do
              tag.div(exercise.title, class: 'exercise-title') +
                tag.div("in #{exercise.track.title}", class: 'track-title')
            end
        end +
          tag.div(class: "counts") do
            safe_join(
              [
                tag.div(class: "count") do
                  graphical_icon(:star) + tag.div(10, class: 'num')
                end,
                tag.div(class: "count") do
                  graphical_icon(:comment) + tag.div(2, class: 'num')
                end
              ]
            )
          end
      end
    end

    def pre_tag
      tag.pre do
        # TODO: Read this from the solution
        tag.code '
public class Year
{
    public static bool IsLeap(int year)
    {
        if (year % 4 != 0) return false
        if (year % 100 == 0 && year % 400) return false
        return true;
    }
}
        '.strip, class: "language-#{highlightjs_language}"
      end
    end

    def footer_tag
      tag.footer do
        safe_join([
                    tag.time("Submitted #{time_ago_in_words(solution.published_at)} ago"),
                    tag.div(class: 'locs') do
                      graphical_icon(:loc) +
                      tag.span("9 lines") # TOOD
                    end
                  ])
      end
    end

    def highlightjs_language
      # TOOD
      "csharp"
    end

    def exercise
      solution.exercise
    end
  end
end
