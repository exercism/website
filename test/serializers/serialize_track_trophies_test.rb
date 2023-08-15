require 'test_helper'

class SerializeTrackTrophiesTest < ActiveSupport::TestCase
  test "includes all track trophies" do
    user = create :user
    prolog = create :track, course: false, slug: 'prolog'
    nim = create :track, course: true, slug: 'nim'

    create :mentored_trophy

    learning_mode_trophy = create :completed_learning_mode_trophy
    learning_mode_trophy.reseed! # Make sure the valid track slugs are up to date

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: "Awarded once you complete a mentoring session in Nim",
        success_message: "Congratulations on completing a mentoring session in Nim",
        icon_name: "trophy-mentored",
        status: :not_earned,
        links: {}
      },
      {
        name: "Fundamental",
        criteria: "Awarded once you complete Learning Mode in Nim",
        success_message: "Congratulations on completing Learning Mode in Nim",
        icon_name: "trophy-completed-learning-mode",
        status: :not_earned,
        links: {}
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(nim, user)

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: "Awarded once you complete a mentoring session in Prolog",
        success_message: "Congratulations on completing a mentoring session in Prolog",
        icon_name: "trophy-mentored",
        status: :not_earned,
        links: {}
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(prolog, user)
  end

  test "returns revealed status for user" do
    user = create :user
    other_user = create :user
    prolog = create :track, course: false, slug: 'prolog'
    nim = create :track, course: true, slug: 'nim'

    mentored_trophy = create :mentored_trophy
    completed_all_exercises_trophy = create :completed_all_exercises_trophy

    learning_mode_trophy = create :completed_learning_mode_trophy
    learning_mode_trophy.reseed! # Make sure the valid track slugs are up to date

    unrevealed_trophy = create :user_track_acquired_trophy, trophy: mentored_trophy, user:, track: nim, revealed: false
    create :user_track_acquired_trophy, trophy: mentored_trophy, user:, track: prolog, revealed: true
    create :user_track_acquired_trophy, trophy: completed_all_exercises_trophy, user: other_user, track: prolog

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: "Awarded once you complete a mentoring session in Nim",
        success_message: "Congratulations on completing a mentoring session in Nim",
        icon_name: "trophy-mentored",
        status: :unrevealed,
        links: {
          reveal: "https://test.exercism.org/api/v2/tracks/nim/trophies/#{unrevealed_trophy.uuid}/reveal"
        }
      },
      {
        name: "Completionist",
        criteria: "Awarded once you complete all exercises in Nim",
        success_message: "Congratulations on completing all exercises in Nim",
        icon_name: "trophy-completed-all-exercises",
        status: :not_earned,
        links: {}
      },
      {
        name: "Fundamental",
        criteria: "Awarded once you complete Learning Mode in Nim",
        success_message: "Congratulations on completing Learning Mode in Nim",
        icon_name: "trophy-completed-learning-mode",
        status: :not_earned,
        links: {}
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(nim, user)

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: "Awarded once you complete a mentoring session in Prolog",
        success_message: "Congratulations on completing a mentoring session in Prolog",
        icon_name: "trophy-mentored",
        status: :revealed,
        links: {}
      },
      {
        name: "Completionist",
        criteria: "Awarded once you complete all exercises in Prolog",
        success_message: "Congratulations on completing all exercises in Prolog",
        icon_name: "trophy-completed-all-exercises",
        status: :not_earned,
        links: {}
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(prolog, user)
  end
end
