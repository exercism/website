require "test_helper"

class Badge::ParticipantIn12In23BadgeTest < ActiveSupport::TestCase
  test "attributes" do
    badge = create :participant_in_12_in_23_badge
    assert_equal "#12in23 Participant", badge.name
    assert_equal :rare, badge.rarity
    assert_equal :'12in23-start', badge.icon
    assert_equal 'Participated in the #12in23 challenge and completed 5 exercises in a track', badge.description
    assert badge.send_email_on_acquisition?
    assert_nil badge.notification_key
  end

  test "award_to?" do
    track = create :track
    user = create :user
    other_track = create :track, :random_slug
    create(:user_track, user:, track:)
    create :user_challenge, user:, challenge_id: '12in23'
    badge = create :participant_in_12_in_23_badge

    # Ignore old iteration
    travel_to Time.utc(2022, 7, 1)
    exercise = create(:practice_exercise, slug: "leap", track:)
    solution = create(:practice_solution, user:, track:, exercise:)
    submission = create(:submission, solution:)
    Iteration::Create.(solution, submission)
    refute badge.award_to?(user.reload)

    # Four iterations on track don't award badge
    travel_to Time.utc(2023, 2, 4)
    %w[allergies anagram bob hamming].each do |slug|
      exercise = create(:practice_exercise, slug:, track:)
      solution = create(:practice_solution, user:, track:, exercise:)
      submission = create(:submission, solution:)
      Iteration::Create.(solution, submission)
      refute badge.award_to?(user.reload)
    end

    # Fifth iteration but on other track does not award badge
    exercise = create :practice_exercise, slug: "leap", track: other_track
    solution = create(:practice_solution, user:, track: other_track, exercise:)
    submission = create(:submission, solution:)
    Iteration::Create.(solution, submission)
    refute badge.award_to?(user.reload)

    # Fifth iteration on track awards badge
    exercise = create(:practice_exercise, slug: "leap", track:)
    solution = create(:practice_solution, user:, track:, exercise:)
    submission = create(:submission, solution:)
    Iteration::Create.(solution, submission)
    assert badge.award_to?(user.reload)
  end
end
