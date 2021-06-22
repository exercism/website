module ReactComponents
  module Journey
    class MentoringSection < ReactComponent
      def to_s
        super("journey-mentoring-section", {
          tracks: [
            {
              title: "C#",
              slug: "csharp",
              num_sessions: 11,
              num_students: 5,
              icon_url: "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/csharp.svg"
            },
            {
              title: "Ruby",
              slug: "ruby",
              num_sessions: 16,
              num_students: 12,
              icon_url: "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/tracks/ruby.svg"
            }
          ],
          ranks: {
            sessions: 1,
            students: 3,
            ratio: nil
          }
        })
      end
    end
  end
end
