require "test_helper"

class User::ProfileTest < ActiveSupport::TestCase
  test "contributions_tab?" do
    user = create :user
    profile = create(:user_profile, user:)
    refute profile.contributions_tab?

    create(:user_published_solution_reputation_token, user:)
    refute profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_code_contribution_reputation_token, user:)
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_exercise_author_reputation_token, user:)
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_code_merge_reputation_token, user:)
    assert profile.reload.contributions_tab?

    User::ReputationToken.destroy_all
    create(:user_arbitrary_reputation_token, user:)
    assert profile.reload.contributions_tab?
  end

  test "badges_tab?" do
    user = create :user
    profile = create(:user_profile, user:)
    refute profile.badges_tab?

    create :user_acquired_badge, user:, badge: create(:rookie_badge), revealed: false
    refute profile.reload.badges_tab?

    create :user_acquired_badge, user:, badge: create(:member_badge), revealed: true
    assert profile.reload.badges_tab?
  end

  test "linkedin accepts linkedin.com urls" do
    [
      "https://linkedin.com/in/foo",
      "https://www.linkedin.com/in/foo",
      "https://uk.linkedin.com/in/foo",
      "https://WWW.LinkedIn.com/in/foo/"
    ].each do |url|
      profile = build(:user_profile, linkedin: url)
      assert profile.valid?, "Expected #{url} to be valid"
      assert_equal url, profile.linkedin_url
    end
  end

  test "linkedin normalises urls without https" do
    assert_equal "https://linkedin.com/in/foo", build(:user_profile, linkedin: "linkedin.com/in/foo").linkedin
    assert_equal "https://www.linkedin.com/in/foo", build(:user_profile, linkedin: "  www.linkedin.com/in/foo ").linkedin
    assert_equal "https://www.linkedin.com/in/foo", build(:user_profile, linkedin: "http://www.linkedin.com/in/foo").linkedin
  end

  test "linkedin can be blank" do
    assert build(:user_profile, linkedin: nil).valid?
    assert build(:user_profile, linkedin: "").valid?
    assert build(:user_profile, linkedin: "  ").valid?
  end

  test "linkedin rejects other urls" do
    [
      "ftp://linkedin.com/in/foo",
      "mailto:foo@linkedin.com",
      "not a url",
      "https://example.com/in/foo",
      "https://notlinkedin.com/in/foo",
      "https://linkedin.com.example.com/in/foo",
      "https://linkedin.com@example.com/in/foo",
      "https://"
    ].each do |url|
      profile = build(:user_profile, linkedin: url)
      refute profile.valid?, "Expected #{url} to be invalid"
      assert_includes profile.errors[:linkedin], "is invalid"
      assert_nil profile.linkedin_url
    end
  end

  test "linkedin_url is nil for existing invalid values" do
    profile = create(:user_profile)
    profile.update_column(:linkedin, "ftp://linkedin.com/in/foo")

    assert_nil profile.reload.linkedin_url
  end

  test "existing invalid linkedin does not block other updates" do
    profile = create(:user_profile)
    profile.update_column(:linkedin, "ftp://linkedin.com/in/foo")
    profile.reload

    assert profile.update(twitter: "foo", linkedin: "ftp://linkedin.com/in/foo")
    assert_equal "foo", profile.reload.twitter
  end
end
