require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  ########
  # Show #
  ########
  test "show: shows a profile" do
    profile = create :user_profile

    get profile_url(profile)
    assert_template "profiles/show"
  end

  test "show: 404s with incorrect handle" do
    sign_in!

    assert_raises ActiveRecord::RecordNotFound do
      get profile_url("foobar")
    end
  end

  test "show: redirects_to intro if own handle" do
    user = create :user
    sign_in!(user)

    get profile_url(user.handle)
    assert_redirected_to intro_profiles_path
  end

  #########
  # Intro #
  #########
  test "intro: shows page" do
    sign_in!

    get intro_profiles_url
    assert_template "profiles/intro"
  end

  test "intro: redirects_to own profile" do
    user = create :user
    create :user_profile, user: user
    sign_in!(user)

    get intro_profiles_url
    assert_redirected_to profile_path(user)
  end

  #######
  # New #
  #######
  test "new: shows page" do
    sign_in!

    get new_profile_url
    assert_template "profiles/new"
  end

  test "new: redirects_to own profile" do
    user = create :user
    create :user_profile, user: user
    sign_in!(user)

    get new_profile_url
    assert_redirected_to profile_path(user)
  end

  ##########
  # Create #
  ##########
  test "create: creates profile" do
    user = create :user
    sign_in!(user)

    post profiles_url
    assert user.reload.profile
    assert_redirected_to profile_path(user)
  end

  test "create: redirects to existing profile" do
    user = create :user
    create :user_profile, user: user
    sign_in!(user)

    post profiles_url
    assert_redirected_to profile_path(user)
  end
end
