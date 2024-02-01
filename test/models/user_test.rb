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

  test "creates data" do
    user = create :user
    assert user.data
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

  test "reputation_for_track" do
    user = create :user
    track = create :track

    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 20, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 18, arbitrary_reason: "" }
    create :user_arbitrary_reputation_token, user:, track:, params: { arbitrary_value: 30, arbitrary_reason: "" }

    assert_equal 20 + 18 + 30, user.reputation_for_track(track)
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
    assert_nil user.pronoun_parts

    user.pronoun_parts = %w[he him his]
    assert_equal "he/him/his", user.pronouns
    assert_equal %w[he him his], user.pronoun_parts

    user.pronoun_parts = ["she", "", "her"]
    assert_equal "she//her", user.pronouns
    assert_nil user.pronoun_parts

    user.pronoun_parts = ["they", "their", ""]
    assert_equal "they/their/", user.pronouns
    assert_nil user.pronoun_parts

    user.pronoun_parts = { 2 => "his", 0 => "he", 1 => "" }
    assert_equal "he//his", user.pronouns
    assert_nil user.pronoun_parts

    user.pronoun_parts = { '2' => "her", '0' => "she", '1' => "" }
    assert_equal "she//her", user.pronouns
    assert_nil user.pronoun_parts
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

  test "scope: insiders" do
    create :user, insiders_status: :unset
    create :user, insiders_status: :ineligible
    create :user, insiders_status: :ineligible
    create :user, insiders_status: :eligible_lifetime
    user_4 = create :user, insiders_status: :active
    user_5 = create :user, insiders_status: :active_lifetime

    assert_equal [user_4, user_5], User.insiders.order(:id)
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

  test "insider?" do
    user = create :user

    %i[unset ineligible eligible eligible_lifetime].each do |insiders_status|
      user.update(insiders_status:)
      refute user.insider?
    end

    %i[active active_lifetime].each do |insiders_status|
      user.update(insiders_status:)
      assert user.insider?
    end
  end

  test "insiders_status is symbol" do
    user = create :user

    user.update(insiders_status: :active)
    assert_equal :active, user.insiders_status
  end

  test "flair is symbol" do
    user = create :user, flair: nil

    assert_nil user.flair

    user.update(flair: :insider)
    assert_equal :insider, user.flair
  end

  test "email verified when email changes" do
    user = create :user

    User::VerifyEmail.expects(:defer).with(user).once

    user.email = 'test@example.org'
    user.skip_reconfirmation!
    user.save!
  end

  test "asset may receive email by default" do
    user = create :user
    assert user.may_receive_emails?
  end

  test "refute may receive email for disabled" do
    user = create :user, disabled_at: Time.current
    refute user.may_receive_emails?
  end

  test "refute may receive email for github" do
    user = create :user, email: "foo@users.noreply.github.com"
    refute user.may_receive_emails?
  end

  test "refute may receive email for invalid email" do
    user = create :user, disabled_at: Time.current
    user.email_status_invalid!
    refute user.may_receive_emails?
  end

  test "refute may receive email for ghost user" do
    user = create :user, :ghost
    refute user.may_receive_emails?
  end

  test "refute may receive email for system user" do
    user = create :user, :system
    refute user.may_receive_emails?
  end

  test "donated_in_last_35_days?" do
    freeze_time do
      user = create :user
      refute user.donated_in_last_35_days?

      create :payments_payment, user:, created_at: Time.current - 36.days
      user.reload
      refute user.donated_in_last_35_days?

      create :payments_payment, user:, created_at: Time.current - 34.days
      user.reload
      assert user.donated_in_last_35_days?
    end
  end

  test "automator?" do
    track = create :track
    user = create :user

    refute user.automator?(track)

    tm = create(:user_track_mentorship, user:, track:)
    refute user.automator?(track)

    # Different track
    create :user_track_mentorship, :automator, user:, track: create(:track, :random_slug)
    refute user.automator?(track)

    tm.update!(automator: true)
    assert user.automator?(track)
  end

  %i[admin staff].each do |role|
    test "automator? enabled for #{role}" do
      track = create :track
      user = create :user, role

      assert user.automator?(track)
    end
  end

  test "trainer?" do
    user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug

    refute user.trainer?(nil)
    refute user.trainer?(track)
    refute user.trainer?(other_track)

    user.update(trainer: true)
    assert user.trainer?(nil)
    refute user.trainer?(track)
    refute user.trainer?(other_track)

    create(:user_track, user:, track:, reputation: 10)
    refute user.eligible_for_trainer?(nil)
    refute user.eligible_for_trainer?(track)
    refute user.eligible_for_trainer?(other_track)

    create(:user_track, user:, track: other_track, reputation: 60)
    assert user.eligible_for_trainer?(nil)
    refute user.eligible_for_trainer?(track)
    assert user.eligible_for_trainer?(other_track)
  end

  %i[admin staff].each do |role|
    test "trainer? enabled for #{role}" do
      track = create :track
      user = create :user, role

      assert user.trainer?(track)
    end
  end

  test "eligible_for_trainer?" do
    user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug

    refute user.eligible_for_trainer?(nil)
    refute user.eligible_for_trainer?(track)
    refute user.eligible_for_trainer?(other_track)

    create(:user_track, user:, track:, reputation: 10)
    refute user.eligible_for_trainer?(nil)
    refute user.eligible_for_trainer?(track)
    refute user.eligible_for_trainer?(other_track)

    create(:user_track, user:, track: other_track, reputation: 60)
    assert user.eligible_for_trainer?(nil)
    refute user.eligible_for_trainer?(track)
    assert user.eligible_for_trainer?(other_track)
  end

  test "validates" do
    user = create :user

    assert_raises ActiveRecord::RecordInvalid do
      user.update!(name: 'a' * 256)
    end
    user.update!(name: 'a' * 255)

    assert_raises ActiveRecord::RecordInvalid do
      user.update!(handle: 'a' * 191)
    end
    user.update!(handle: 'a' * 190)

    assert_raises ActiveRecord::RecordInvalid do
      user.update!(email: "#{'a' * 182}@test.org")
    end
    user.update!(email: "#{'a' * 181}@test.org")

    assert_raises ActiveRecord::RecordInvalid do
      user.update!(pronouns: 'a' * 256)
    end
    user.update!(pronouns: 'a' * 255)

    assert_raises ActiveRecord::RecordInvalid do
      user.update!(location: 'a' * 256)
    end

    user.update!(location: 'a' * 255)
  end

  test "watched_video?" do
    user = create :user
    provider = :youtube
    id = "asdsaeqwe31231"

    # Different person
    create :user_watched_video, video_provider: provider, video_id: id
    #
    # Different video
    create(:user_watched_video, user:)

    refute user.watched_video?(provider, id)

    create :user_watched_video, user:, video_provider: provider, video_id: id
    assert user.watched_video?(provider, id)
  end
end
