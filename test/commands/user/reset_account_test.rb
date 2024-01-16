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
      became_mentor_at: Time.current,
      version: 10

    User::InvalidateAvatarInCloudfront.expects(:defer).with(user)

    perform_enqueued_jobs do
      User::ResetAccount.(user)
    end

    user.reload
    assert_equal 0, user.reputation
    assert_equal 11, user.version
    assert_empty user.roles
    assert_nil user.bio

    assert_nil user.attributes["avatar_url"]

    assert_nil user.location
    assert_nil user.pronouns
    assert_nil user.became_mentor_at
  end

  test "resets tracks" do
    freeze_time do
      ruby = create :track, slug: :ruby
      js = create :track, slug: :js

      user = create :user
      user_track_1 = create :user_track, user:, track: ruby
      user_track_2 = create :user_track, user:, track: js
      orphaned_solution = create :practice_solution, user:, track: create(:track, :random_slug)

      pending_request = create :mentor_request, solution: create(:practice_solution, user:)
      fulfilled_request = create :mentor_request, :fulfilled, solution: create(:practice_solution, user:)

      UserTrack::Destroy.expects(:call).with(user_track_1)
      UserTrack::Destroy.expects(:call).with(user_track_2)
      UserTrack::Destroy.expects(:call).with do |ut|
        ut.track == orphaned_solution.track && ut.user == user
      end

      User::ResetAccount.(user)

      assert_raises ActiveRecord::RecordNotFound do
        pending_request.reload
      end

      assert_equal User::GHOST_USER_ID, fulfilled_request.reload.student_id
    end
  end

  test "resets mentorships" do
    ghost_user = create :user, :ghost

    user = create :user
    discussion = create :mentor_discussion, mentor: user
    discussion_post = create :mentor_discussion_post, author: user
    testimonial = create :mentor_testimonial, mentor: user
    provided_testimonial = create :mentor_testimonial, student: user
    submission_representation = create :submission_representation, mentored_by: user

    User::ResetAccount.(user)

    assert_equal ghost_user, discussion.reload.mentor
    assert_equal ghost_user, discussion_post.reload.author
    assert_equal ghost_user, testimonial.reload.mentor
    assert_equal ghost_user, provided_testimonial.reload.student
    assert_nil submission_representation.reload.mentored_by
  end

  test "cleans up profile" do
    user = create :user
    profile = create(:user_profile, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      profile.reload
    end
  end

  test "cleans up activities" do
    user = create :user
    activity = create(:started_exercise_user_activity, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      activity.reload
    end
  end

  test "cleans up notifications" do
    user = create :user
    notification = create(:notification, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      notification.reload
    end
  end

  test "cleans up reputation_tokens" do
    user = create :user
    reputation_token = create(:user_reputation_token, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      reputation_token.reload
    end
  end

  test "cleans up reputation_periods" do
    user = create :user
    reputation_period = create(:user_reputation_period, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      reputation_period.reload
    end
  end

  test "cleans up acquired_badges that no longer should be awarded" do
    user = create :user, github_username: 'ihid'

    member_badge = create :member_badge
    moss_badge = create :moss_badge
    completer_badge = create :completer_badge
    whatever_badge = create :whatever_badge

    member_acquired_badge = create :user_acquired_badge, user:, badge: member_badge
    moss_acquired_badge = create :user_acquired_badge, user:, badge: moss_badge
    completer_acquired_badge = create :user_acquired_badge, user:, badge: completer_badge
    whatever_acquired_badge = create :user_acquired_badge, user:, badge: whatever_badge

    User::ResetAccount.(user)

    user.reload
    assert_equal 2, user.acquired_badges.size

    # The user should keep the member and moss badges as resetting
    # the other data does not influence those badges
    assert_includes user.acquired_badges, member_acquired_badge
    assert_includes user.acquired_badges, moss_acquired_badge

    # The user should lose the completer and whatever badges as resetting
    # the other data does influence those badges
    refute_includes user.acquired_badges, completer_acquired_badge
    refute_includes user.acquired_badges, whatever_acquired_badge
  end

  test "cleans up track_mentorships" do
    user = create :user
    track_mentorship = create(:user_track_mentorship, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      track_mentorship.reload
    end
  end

  test "cleans up scratchpad_pages" do
    user = create :user
    scratchpad_page = create :scratchpad_page, author: user
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      scratchpad_page.reload
    end
  end

  test "cleans up solution_stars" do
    user = create :user
    solution_star = create(:solution_star, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      solution_star.reload
    end
  end

  test "cleans up solution_tags" do
    ghost_user = create :user, :ghost
    user = create :user
    solution_tag = create(:solution_tag, user:)
    User::ResetAccount.(user)
    assert_equal ghost_user, solution_tag.reload.user
  end

  test "cleans up problem reports" do
    create :user, :ghost
    user = create :user
    pr = create(:problem_report, user:)

    User::ResetAccount.(user)

    assert_equal User::GHOST_USER_ID, pr.reload.user_id
  end

  test "cleans up challenges" do
    user = create :user
    challenge = create(:user_challenge, user:)
    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      challenge.reload
    end
  end

  test "cleans up viewed community solutions" do
    create :user, :ghost
    user = create :user
    viewed_solution = create(:user_track_viewed_community_solution, user:)

    User::ResetAccount.(user)
    assert_raises ActiveRecord::RecordNotFound do
      viewed_solution.reload
    end
  end
end
