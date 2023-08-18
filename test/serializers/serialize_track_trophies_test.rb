require 'test_helper'

class SerializeTrackTrophiesTest < ActiveSupport::TestCase
  test "includes all track trophies" do
    user = create :user
    prolog = create :track, course: false, slug: 'prolog'
    nim = create :track, course: true, slug: 'nim'

    mentored_trophy = create :mentored_trophy

    learning_mode_trophy = create :completed_learning_mode_trophy
    learning_mode_trophy.reseed! # Make sure the valid track slugs are up to date

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: mentored_trophy.criteria(nim),
        success_message: mentored_trophy.success_message(nim),
        icon_name: "trophy-mentored",
        num_awardees: 0,
        awarded_at: nil,
        status: :not_earned,
        links: {},
        track: { title: nim.title }
      },
      {
        name: "Fundamental",
        criteria: learning_mode_trophy.criteria(nim),
        success_message: learning_mode_trophy.success_message(nim),
        icon_name: "trophy-completed-learning-mode",
        num_awardees: 0,
        awarded_at: nil,
        status: :not_earned,
        links: {},
        track: { title: nim.title }
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(nim, user)

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: mentored_trophy.criteria(prolog),
        success_message: mentored_trophy.success_message(prolog),
        icon_name: "trophy-mentored",
        num_awardees: 0,
        awarded_at: nil,
        status: :not_earned,
        links: {},
        track: { title: prolog.title }
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

    user_trophies_acquired_at = Time.current - 1.week
    unrevealed_trophy = create :user_track_acquired_trophy, trophy: mentored_trophy, user:, track: nim, revealed: false,
      created_at: user_trophies_acquired_at
    create :user_track_acquired_trophy, trophy: mentored_trophy, user:, track: prolog, revealed: true,
      created_at: user_trophies_acquired_at
    create :user_track_acquired_trophy, trophy: completed_all_exercises_trophy, user: other_user, track: prolog

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: mentored_trophy.criteria(nim),
        success_message: mentored_trophy.success_message(nim),
        icon_name: "trophy-mentored",
        num_awardees: 2,
        awarded_at: user_trophies_acquired_at.iso8601,
        status: :unrevealed,
        links: {
          reveal: "https://test.exercism.org/api/v2/tracks/nim/trophies/#{unrevealed_trophy.uuid}/reveal"
        },
        track: { title: nim.title }
      },
      {
        name: "Exemplary Expert",
        criteria: completed_all_exercises_trophy.criteria(nim),
        success_message: completed_all_exercises_trophy.success_message(nim),
        icon_name: "trophy-completed-all-exercises",
        num_awardees: 1,
        awarded_at: nil,
        status: :not_earned,
        links: {},
        track: { title: nim.title }
      },
      {
        name: "Fundamental",
        criteria: learning_mode_trophy.criteria(nim),
        success_message: learning_mode_trophy.success_message(nim),
        icon_name: "trophy-completed-learning-mode",
        num_awardees: 0,
        awarded_at: nil,
        status: :not_earned,
        links: {},
        track: { title: nim.title }
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(nim, user)

    expected = [
      {
        name: "Magnificent Mentee",
        criteria: mentored_trophy.criteria(prolog),
        success_message: mentored_trophy.success_message(prolog),
        icon_name: "trophy-mentored",
        num_awardees: 2,
        awarded_at: user_trophies_acquired_at.iso8601,
        status: :revealed,
        links: {},
        track: { title: prolog.title }
      },
      {
        name: "Exemplary Expert",
        criteria: completed_all_exercises_trophy.criteria(prolog),
        success_message: completed_all_exercises_trophy.success_message(prolog),
        icon_name: "trophy-completed-all-exercises",
        num_awardees: 1,
        awarded_at: nil,
        status: :not_earned,
        links: {},
        track: { title: prolog.title }
      }
    ]
    assert_equal expected, SerializeTrackTrophies.(prolog, user)
  end
end
