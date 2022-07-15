require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "#for! with model" do
    user = random_of_many(:user)
    assert_equal user, User.for!(user)
  end

  test "#for! with id" do
    user = random_of_many(:user)
    assert_equal user, User.for!(user.id)
  end

  test "#for! with handle" do
    user = random_of_many(:user)
    assert_equal user, User.for!(user.handle)
  end

  test "creates communication_preferences" do
    user = create :user
    assert user.communication_preferences
  end

  test "defaults name to handle correctly" do
    name = "Someone"
    handle = "soooomeone"
    user = User.create!(name:, handle:, email: "who@where.com", password: "foobar")
    assert_equal name, user.name

    handle = "eeeelllseee"
    user = User.create!(handle:, email: "who@there.com", password: "foobar")
    assert_equal handle, user.name
  end

  test "reputation sums correctly" do
    user = create :user
    create :user_code_contribution_reputation_token # Random token for different user

    create :user_exercise_contribution_reputation_token, user: user
    create :user_exercise_author_reputation_token, user: user
    create :user_code_contribution_reputation_token, user: user, level: :large
    create :user_code_contribution_reputation_token, user: user, level: :medium

    assert_equal 72, user.reload.reputation
    # assert_equal 20, user.reputation(track_slug: :ruby)
    assert_equal 30, user.reputation(category: :authoring)
  end

  test "reputation raises with both track_slug and category specified" do
    user = create :user

    # Sanity check the individuals work
    # before testing them both together
    assert user.reputation(track_slug: :ruby)
    assert user.reputation(category: :docs)
    assert_raises do
      user.reputation(track_slug: :ruby, category: :docs)
    end
  end

  test "formatted_reputation works" do
    assert_equal "123k", create(:user, reputation: 123_456).formatted_reputation
  end

  test "has_badge?" do
    badge = create :rookie_badge
    user = create :user
    refute user.has_badge?(:rookie)

    create :user_acquired_badge, badge: badge, user: user
    assert user.reload.has_badge?(:rookie)
  end

  test "joined_track?" do
    user = create :user
    user_track = create :user_track, user: user
    track = create :track, :random_slug

    assert user.joined_track?(user_track.track)
    refute user.joined_track?(track)
  end

  # TODO: Remove if not used by launch
  # test "#favorited_by? returns false if no relationship exists" do
  #   mentor = create :user
  #   student = create :user

  #   refute student.favorited_by?(mentor)
  # end

  # test "#favorited_by? returns false if relationship is not a favorite" do
  #   mentor = create :user
  #   student = create :user
  #   create :mentor_student_relationship, mentor: mentor, student: student, favorited: false

  #   refute student.favorited_by?(mentor)
  # end

  # test "#favorited_by? returns true if relationship is a favorite" do
  #   mentor = create :user
  #   student = create :user
  #   create :mentor_student_relationship, mentor: mentor, student: student, favorited: true

  #   assert student.favorited_by?(mentor)
  # end

  test "unrevealed_badges" do
    user = create :user
    rookie_badge = create :rookie_badge
    member_badge = create :member_badge

    create :user_acquired_badge, revealed: true, badge: rookie_badge, user: user
    create :user_acquired_badge, revealed: false, badge: rookie_badge
    unrevealed = create :user_acquired_badge, revealed: false, badge: member_badge, user: user

    assert_equal [unrevealed], user.unrevealed_badges
  end

  test "featured_badges" do
    user = create :user

    common_badge_1 = create :rookie_badge
    common_badge_2 = create :member_badge
    rare_badge_1 = create :all_your_base_badge
    ultimate_badge_1 = create :lackadaisical_badge
    legendary_badge_1 = create :begetter_badge
    legendary_badge_2 = create :moss_badge

    create :user_acquired_badge, user: user, badge: rare_badge_1, revealed: true
    create :user_acquired_badge, user: user, badge: common_badge_1, revealed: true
    create :user_acquired_badge, user: user, badge: legendary_badge_1, revealed: true
    create :user_acquired_badge, user: user, badge: common_badge_2, revealed: true
    create :user_acquired_badge, user: user, badge: legendary_badge_2, revealed: true
    create :user_acquired_badge, user: user, badge: ultimate_badge_1, revealed: true

    assert_equal [legendary_badge_2, legendary_badge_1, ultimate_badge_1, rare_badge_1, common_badge_2],
      user.featured_badges.order('id desc')
  end

  test "revealed_badges" do
    user = create :user

    common_badge = create :rookie_badge
    rare_badge = create :supporter_badge
    ultimate_badge = create :lackadaisical_badge
    legendary_badge = create :begetter_badge

    create :user_acquired_badge, revealed: true, user: user, badge: rare_badge
    create :user_acquired_badge, revealed: false, user: user, badge: legendary_badge
    create :user_acquired_badge, revealed: true, user: user, badge: common_badge
    create :user_acquired_badge, revealed: false, user: user, badge: ultimate_badge

    assert_equal [common_badge, rare_badge], user.revealed_badges.sort_by(&:name)
  end

  test "featured_badges only returns revealed badges" do
    user = create :user

    common_badge = create :rookie_badge
    rare_badge = create :supporter_badge
    ultimate_badge = create :lackadaisical_badge
    legendary_badge = create :begetter_badge

    create :user_acquired_badge, revealed: true, user: user, badge: rare_badge
    create :user_acquired_badge, revealed: false, user: user, badge: legendary_badge
    create :user_acquired_badge, revealed: true, user: user, badge: common_badge
    create :user_acquired_badge, revealed: false, user: user, badge: ultimate_badge

    assert_equal [rare_badge, common_badge], user.featured_badges
  end

  test "mentor?" do
    user = create :user, became_mentor_at: nil
    refute user.mentor?

    user.update(became_mentor_at: Time.current)
    assert user.mentor?
  end

  test "recently_used_cli?" do
    freeze_time do
      user = create :user

      refute user.recently_used_cli?

      solution = create :practice_solution, user: user
      refute user.recently_used_cli?

      solution.update(downloaded_at: Time.current - 31.days)
      refute user.recently_used_cli?

      solution.update(downloaded_at: Time.current - 30.days)
      assert user.recently_used_cli?
    end
  end

  test "auth_token" do
    user = create :user
    create :user_auth_token, user: user, active: false
    token = create :user_auth_token, user: user, active: true
    create :user_auth_token, user: user, active: false

    assert_equal token.token, user.auth_token
  end

  test "create_auth_token!" do
    user = create :user

    user.create_auth_token!
    token_1 = user.auth_tokens.first

    assert_equal 1, user.auth_tokens.size
    assert token_1.active?

    user.create_auth_token!
    token_1.reload
    token_2 = user.auth_tokens.last

    assert_equal 2, user.auth_tokens.size
    refute token_1.active?
    assert token_2.active?
  end

  test "pronoun_parts" do
    user = create :user
    assert_nil user.pronouns
    assert_equal ['', '', ''], user.pronoun_parts

    user.pronoun_parts = %w[he him his]
    assert_equal "he/him/his", user.pronouns
    assert_equal %w[he him his], user.pronoun_parts

    user.pronoun_parts = ["she", "", "her"]
    assert_equal "she//her", user.pronouns
    assert_equal ["she", "", "her"], user.pronoun_parts

    user.pronoun_parts = ["they", "their", ""]
    assert_equal "they/their/", user.pronouns
    assert_equal ["they", "their", ""], user.pronoun_parts

    user.pronoun_parts = { 2 => "his", 0 => "he", 1 => "" }
    assert_equal "he//his", user.pronouns
    assert_equal ["he", "", "his"], user.pronoun_parts

    user.pronoun_parts = { '2' => "her", '0' => "she", '1' => "" }
    assert_equal "she//her", user.pronouns
    assert_equal ["she", "", "her"], user.pronoun_parts
  end

  test "dismiss_introducer!" do
    user = create :user
    refute user.introducer_dismissed?('scratchpad')

    user.dismiss_introducer!('scratchpad')
    assert user.introducer_dismissed?('scratchpad')
  end

  test "teams" do
    user = create :user
    team_1 = create :contributor_team, :random
    team_2 = create :contributor_team, :random, track: nil
    create :contributor_team_membership, team: team_1, user: user
    create :contributor_team_membership, team: team_2, user: user

    assert_equal [team_1, team_2], user.teams
  end

  test "welcome email is not sent for normal user creation" do
    User::Notification::CreateEmailOnly.expects(:call).never
    create :user
  end

  test "welcome email is sent after confirmation" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:call).with(user, :joined_exercism, {})

    user.confirm
  end

  test "welcome email is sent when a confirmed user is created" do
    user = build :user
    user.skip_confirmation!

    User::Notification::CreateEmailOnly.expects(:call).with(user, :joined_exercism, {})

    user.save!
  end

  test "may_create_profile?" do
    user = build :user, reputation: 0
    refute user.may_create_profile?

    user.update(reputation: 4)
    refute user.may_create_profile?

    user.update(reputation: 5)
    assert user.may_create_profile?
  end
end
