class AssembleJourneyOverview
  include Mandate

  initialize_with :user

  def call
    {
      overview: {
        learning: {
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
        },
        mentoring: {
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
        },
        contributing: AssembleContributionsSummary.(user),
        badges: {
          badges: SerializeUserAcquiredBadges.(user.acquired_badges.revealed),
          links: {
            badges: Exercism::Routes.badges_journey_url
          }
        }
      }
    }
  end
end
