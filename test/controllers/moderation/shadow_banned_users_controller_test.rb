require "test_helper"

class Moderation::ShadowBannedUsersControllerTest < ActionDispatch::IntegrationTest
  test "index redirects if not signed in" do
    get moderation_shadow_banned_users_url

    assert_response :redirect
  end

  test "index redirects if not moderator" do
    sign_in!

    get moderation_shadow_banned_users_url

    assert_response :redirect
  end

  test "index succeeds for moderator" do
    user = create(:user, :staff)

    sign_in!(user)

    get moderation_shadow_banned_users_url

    assert_response :success
  end

  test "create shadow bans a user" do
    moderator = create(:user, :staff)
    student = create :user

    sign_in!(moderator)

    post moderation_shadow_banned_users_url, params: { handle: student.handle }

    student.reload
    assert student.shadow_banned?
    assert_equal moderator.id, student.shadow_banned_by_id
    assert_redirected_to moderation_shadow_banned_users_url
  end

  test "create handles unknown handle" do
    moderator = create(:user, :staff)
    sign_in!(moderator)

    post moderation_shadow_banned_users_url, params: { handle: "nonexistent" }

    assert_redirected_to moderation_shadow_banned_users_url
  end

  test "destroy removes shadow ban" do
    moderator = create(:user, :staff)
    student = create :user, shadow_banned_at: Time.current, shadow_banned_by_id: moderator.id

    sign_in!(moderator)

    delete moderation_shadow_banned_user_url(student)

    student.reload
    refute student.shadow_banned?
    assert_nil student.shadow_banned_by_id
    assert_redirected_to moderation_shadow_banned_users_url
  end
end
