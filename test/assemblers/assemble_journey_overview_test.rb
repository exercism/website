require "test_helper"

class AssembleJourneyOverviewTest < ActiveSupport::TestCase
  test "with new user" do
    user = create :user
    expected = {
      overview: {
        learning: {
          tracks: [],
          links: {
            solutions: Exercism::Routes.solutions_journey_url,
            fable: "#"
          }
        },
        mentoring: {
          tracks: [],
          totals: {
            discussions: 0,
            students: 0,
            ratio: 0
          },
          ranks: {
            discussions: 1,
            students: 3
          }
        },
        contributing: AssembleContributionsSummary.(user, for_self: true),
        badges: {
          badges: SerializeUserAcquiredBadges.(user.acquired_badges.revealed),
          links: {
            badges: Exercism::Routes.badges_journey_url
          }
        }
      }
    }

    assert_equal expected, AssembleJourneyOverview.(user)
  end

  test "with learning tracks" do
    track = create :track
    user = create :user
    create :user_track, user: user, track: track
    UserTrack.any_instance.expects(num_exercises: 10)
    UserTrack.any_instance.expects(num_completed_exercises: 5)
    UserTrack.any_instance.expects(num_concepts_learnt: 2)
    UserTrack.any_instance.expects(num_started_exercises: 7)

    expected = {
      tracks: [{
        title: track.title,
        slug: track.slug,
        num_exercises: 10,
        num_completed_exercises: 5,
        num_concepts_learnt: 2,
        icon_url: track.icon_url,
        num_lines: 250,
        num_solutions: 7
      }],
      links: {
        solutions: Exercism::Routes.solutions_journey_url,
        fable: "#"
      }
    }

    assert_equal expected, AssembleJourneyOverview.(user)[:overview][:learning]
  end

  test "with mentoring tracks" do
    ruby = create :track, slug: :ruby
    js = create :track, slug: :js

    mentor = create :user
    student_1 = create :user
    student_2 = create :user
    create :mentor_discussion, mentor: mentor, solution: create(:practice_solution, user: student_1, track: ruby)
    create :mentor_discussion, mentor: mentor, solution: create(:practice_solution, user: student_1, track: js)
    create :mentor_discussion, mentor: mentor, solution: create(:practice_solution, user: student_2, track: js)
    create :mentor_discussion, mentor: mentor, solution: create(:practice_solution, user: student_1, track: js)

    # Unused records to ensure they're filtered
    create :mentor_discussion, solution: create(:practice_solution, user: student_2, track: js)
    create :track, slug: :csharp

    expected = {
      tracks: [{
        title: js.title,
        slug: js.slug,
        icon_url: js.icon_url,
        num_discussions: 3,
        num_students: 2
      }, {
        title: ruby.title,
        slug: ruby.slug,
        icon_url: ruby.icon_url,
        num_discussions: 1,
        num_students: 1
      }],
      totals: {
        discussions: 4,
        students: 2,
        ratio: 2
      },
      ranks: {
        discussions: 1,
        students: 3
      }
    }

    assert_equal expected, AssembleJourneyOverview.(mentor)[:overview][:mentoring]
  end
end
