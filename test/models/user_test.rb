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

  test "creates preferences" do
    user = create :user
    assert user.preferences
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

    create(:user_exercise_contribution_reputation_token, user:)
    create(:user_exercise_author_reputation_token, user:)
    create :user_code_contribution_reputation_token, user:, level: :large
    create :user_code_contribution_reputation_token, user:, level: :medium

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

    create(:user_acquired_badge, badge:, user:)
    assert user.reload.has_badge?(:rookie)
  end

  test "joined_track?" do
    user = create :user
    user_track = create(:user_track, user:)
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

    create(:user_acquired_badge, revealed: true, badge: rookie_badge, user:)
    create :user_acquired_badge, revealed: false, badge: rookie_badge
    unrevealed = create(:user_acquired_badge, revealed: false, badge: member_badge, user:)

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

    create :user_acquired_badge, user:, badge: rare_badge_1, revealed: true
    create :user_acquired_badge, user:, badge: common_badge_1, revealed: true
    create :user_acquired_badge, user:, badge: legendary_badge_1, revealed: true
    create :user_acquired_badge, user:, badge: common_badge_2, revealed: true
    create :user_acquired_badge, user:, badge: legendary_badge_2, revealed: true
    create :user_acquired_badge, user:, badge: ultimate_badge_1, revealed: true

    assert_equal [legendary_badge_2, legendary_badge_1, ultimate_badge_1, rare_badge_1, common_badge_2],
      user.featured_badges.order('id desc')
  end

  test "revealed_badges" do
    user = create :user

    common_badge = create :rookie_badge
    rare_badge = create :supporter_badge
    ultimate_badge = create :lackadaisical_badge
    legendary_badge = create :begetter_badge

    create :user_acquired_badge, revealed: true, user:, badge: rare_badge
    create :user_acquired_badge, revealed: false, user:, badge: legendary_badge
    create :user_acquired_badge, revealed: true, user:, badge: common_badge
    create :user_acquired_badge, revealed: false, user:, badge: ultimate_badge

    assert_equal [common_badge, rare_badge], user.revealed_badges.sort_by(&:name)
  end

  test "featured_badges only returns revealed badges" do
    user = create :user

    common_badge = create :rookie_badge
    rare_badge = create :supporter_badge
    ultimate_badge = create :lackadaisical_badge
    legendary_badge = create :begetter_badge

    create :user_acquired_badge, revealed: true, user:, badge: rare_badge
    create :user_acquired_badge, revealed: false, user:, badge: legendary_badge
    create :user_acquired_badge, revealed: true, user:, badge: common_badge
    create :user_acquired_badge, revealed: false, user:, badge: ultimate_badge

    assert_equal [rare_badge, common_badge], user.featured_badges
  end

  test "recently_used_cli?" do
    freeze_time do
      user = create :user

      refute user.recently_used_cli?

      solution = create(:practice_solution, user:)
      refute user.recently_used_cli?

      solution.update(downloaded_at: Time.current - 31.days)
      refute user.recently_used_cli?

      solution.update(downloaded_at: Time.current - 30.days)
      assert user.recently_used_cli?
    end
  end

  test "auth_token" do
    user = create :user
    create :user_auth_token, user:, active: false
    token = create :user_auth_token, user:, active: true
    create :user_auth_token, user:, active: false

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

  test "welcome email is not sent for normal user creation" do
    User::Notification::CreateEmailOnly.expects(:call).never
    create :user
  end

  test "welcome email is sent after confirmation" do
    user = create :user

    User::Notification::CreateEmailOnly.expects(:call).with(user, :joined_exercism)

    user.confirm
  end

  test "welcome email is sent when a confirmed user is created" do
    user = build :user
    user.skip_confirmation!

    User::Notification::CreateEmailOnly.expects(:call).with(user, :joined_exercism)

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

  test "profile?" do
    user = create :user
    refute user.profile?

    create(:user_profile, user:)

    assert user.reload.profile?
  end

  test "confirmed?" do
    user = create :user, email: 'test@invalid.org', confirmed_at: nil, disabled_at: nil
    refute user.confirmed?

    user.update(confirmed_at: Time.current)
    assert user.confirmed?

    block_domain = create :user_block_domain, domain: 'invalid.org'
    refute user.confirmed?

    block_domain.delete
    assert user.confirmed?

    user.update(disabled_at: Time.current)
    refute user.confirmed?
  end

  test "blocked?" do
    user = create :user, email: 'test@invalid.org'
    refute user.blocked?

    create :user_block_domain, domain: 'invalid.org'
    assert user.blocked?
  end

  test "disabled?" do
    user = create :user, disabled_at: nil
    refute user.disabled?

    user.update(disabled_at: Time.current)
    assert user.disabled?
  end

  test "donated?" do
    user = create :user, first_donated_at: nil
    refute user.donated?

    user.update(first_donated_at: Time.current)
    assert user.donated?
  end

  test "scope: random" do
    create_list(:user, 100)
    refute_equal User.all, User.random
  end

  test "scope: donor" do
    create :user, first_donated_at: nil
    user_2 = create :user, first_donated_at: Time.current, show_on_supporters_page: false
    user_3 = create :user, first_donated_at: Time.current, show_on_supporters_page: true

    assert_equal [user_2, user_3], User.donor.order(:id)
  end

  test "scope: public_supporter" do
    create :user, first_donated_at: nil
    create :user, first_donated_at: Time.current, show_on_supporters_page: false
    user_3 = create :user, first_donated_at: Time.current, show_on_supporters_page: true

    assert_equal [user_3], User.public_supporter.order(:id)
  end

  test "github_auth?" do
    user = create :user, uid: nil
    refute user.github_auth?

    user.update(uid: 'aiqweqwe')
    assert user.github_auth?
  end

  test "captcha_required?" do
    user = create :user, uid: nil, created_at: Time.current
    assert user.captcha_required?

    user.update(uid: nil, created_at: Time.current - 4.days)
    refute user.captcha_required?

    user.update(uid: 'aiqweqwe', created_at: Time.current)
    refute user.captcha_required?

    user.update(uid: 'aiqweqwe', created_at: Time.current - 4.days)
    refute user.captcha_required?
  end

  test "github_team_memberships" do
    user = create :user, uid: '182346'
    other_user = create :user, uid: '769032'
    assert_empty user.github_team_memberships

    team_member_1 = create :github_team_member, user_id: user.uid
    assert_equal [team_member_1], user.reload.github_team_memberships

    team_member_2 = create :github_team_member, user_id: user.uid
    assert_equal [team_member_1, team_member_2].sort, user.reload.github_team_memberships.sort

    # Sanity check: other user
    create :github_team_member, user_id: other_user.uid
    assert_equal [team_member_1, team_member_2].sort, user.reload.github_team_memberships.sort
  end

  test "insiders_status is symbol" do
    user = create :user

    user.update(insiders_status: :active)
    assert_equal :active, user.insiders_status
  end

  test "insiders_status is updated when active_donation_subscription changes" do
    user = create :user, active_donation_subscription: false, insiders_status: :ineligible

    perform_enqueued_jobs do
      user.update(active_donation_subscription: true)
      assert_equal :eligible, user.reload.insiders_status

      user.update(active_donation_subscription: false)
      assert_equal :ineligible, user.reload.insiders_status
    end
  end

  test "insiders_status is updated when roles change" do
    user = create :user, roles: []

    perform_enqueued_jobs do
      user.update(roles: [:maintainer])
      assert_equal :eligible, user.reload.insiders_status

      user.update(roles: [])
      assert_equal :ineligible, user.reload.insiders_status
    end
  end

  test "insiders_status is updated when reputation changes" do
    user = create :user, reputation: 0

    perform_enqueued_jobs do
      user.update(reputation: 1_000)
      assert_equal :eligible, user.reload.insiders_status

      user.update(reputation: 0)
      assert_equal :ineligible, user.reload.insiders_status
    end
  end

  test "insiders_status is not updated when other non-related column changes" do
    user = create :user, insiders_status: :active

    perform_enqueued_jobs do
      user.update(name: 'New name')

      # Would have been :ineligible if the status were updated
      assert_equal :active, user.reload.insiders_status
    end
  end
end
