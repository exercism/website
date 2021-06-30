require "test_helper"

class User::ResetAccountTest < ActiveSupport::TestCase
  test "cleans up attributes" do
    user = create :user,
      reputation: 10,
      roles: [:admin],
      bio: "something",
      avatar_url: "somewhere",
      location: "here",
      pronouns: "there",
      became_mentor_at: Time.current

    User::ResetAccount.(user)

    assert_equal 0, user.reputation
    assert_empty user.roles
    assert_nil user.bio

    # TODO: Switch
    # assert_equal "https://exercism-icons-staging.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg", user.avatar_url
    assert_includes user.avatar_url, "https://100k-faces.glitch.me/random-image"

    assert_nil user.location
    assert_nil user.pronouns
    assert_nil user.became_mentor_at
  end

  test "resets tracks" do
    freeze_time do
      ruby = create :track, slug: :ruby
      js = create :track, slug: :js

      user = create :user
      user_track_1 = create :user_track, user: user, track: ruby
      user_track_2 = create :user_track, user: user, track: js

      request = create :mentor_request, solution: create(:practice_solution, user: user)

      UserTrack::Destroy.expects(:call).with(user_track_1)
      UserTrack::Destroy.expects(:call).with(user_track_2)

      User::ResetAccount.(user)

      assert_raises ActiveRecord::RecordNotFound do
        request.reload
      end
    end
  end

  test "resets mentorships" do
    ghost_user = create :user, :ghost

    user = create :user
    discussion = create :mentor_discussion, mentor: user
    testimonial = create :mentor_testimonial, mentor: user

    User::ResetAccount.(user)

    assert_equal ghost_user, discussion.reload.mentor
    assert_equal ghost_user, testimonial.reload.mentor
  end

  test "cleans up profile" do
    user = create :user
    profile = create :user_profile, user: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      profile.reload
    end
  end

  test "cleans up activities" do
    user = create :user
    activity = create :started_exercise_user_activity, user: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      activity.reload
    end
  end

  test "cleans up notifications" do
    user = create :user
    notification = create :notification, user: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      notification.reload
    end
  end

  test "cleans up reputation_tokens" do
    user = create :user
    reputation_token = create :user_reputation_token, user: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      reputation_token.reload
    end
  end

  test "cleans up acquired_badges" do
    user = create :user
    acquired_badge = create :user_acquired_badge, user: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      acquired_badge.reload
    end
  end

  test "cleans up track_mentorships" do
    user = create :user
    track_mentorship = create :user_track_mentorship, user: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      track_mentorship.reload
    end
  end
end
