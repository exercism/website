module ReactComponents
  module Journey
    class LearningSection < ReactComponent
      def to_s
        super("journey-learning-section", {
          tracks: [
            {
              title: "C#",
              slug: "csharp",
              num_exercises: 11,
              num_completed_exercises: 5,
              num_concepts_learnt: 5,
              icon_url: "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/csharp.svg",
              num_lines: 250,
              num_solutions: 10
            },
            {
              title: "Ruby",
              slug: "ruby",
              num_exercises: 13,
              num_completed_exercises: 13,
              num_concepts_learnt: 3,
              icon_url: "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/ruby.svg",
              num_lines: 200,
              num_solutions: 3
            }
          ],
          links: {
            solutions: "#",
            fable: "#"
          }
        })
      end
    end
  end
end
