require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  ########
  # Show #
  ########
  test "show: 404s silently for missing user" do
    get profile_url('foobar')

    assert_rendered_404
  end

  test "show: 404s silently for missing profile" do
    get profile_url(create(:user).handle)

    assert_rendered_404
  end

  test "show: shows a profile" do
    profile = create :user_profile

    get profile_url(profile)
    assert_template "profiles/show"
  end

  test "show: redirects_to intro if own handle" do
    user = create :user
    sign_in!(user)

    get profile_url(user.handle)
    assert_redirected_to intro_profiles_path
  end

  test "show doesn't include unpublished testimonials" do
    skip # TODO: (optional)
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
    create(:user_profile, user:)
    sign_in!(user)

    get intro_profiles_url
    assert_redirected_to profile_path(user)
  end

  #######
  # New #
  #######
  test "new: shows page" do
    user = create :user, reputation: 10
    sign_in!(user)

    get new_profile_url
    assert_template "profiles/new"
  end

  test "new: redirects_to own profile" do
    user = create :user, reputation: 10
    create(:user_profile, user:)
    sign_in!(user)

    get new_profile_url
    assert_redirected_to profile_path(user)
  end

  test "new: redirects to intro if the user hasn't unlocked creating a profile" do
    user = create :user, reputation: 0
    sign_in!(user)

    get new_profile_url
    assert_redirected_to intro_profiles_path
  end

  ################
  # Testimonials #
  ################
  test "testimonials doesn't include unpublished testimonials" do
    skip # TODO: (optional)
  end

  test "testimonials redirects to profile page if user does not have contributions" do
    user = create :user
    create(:user_profile, user:)

    get testimonials_profile_url(user)

    assert_redirected_to profile_path(user)
  end

  #################
  # Contributions #
  #################
  test "contributions redirects to profile page if user does not have contributions" do
    user = create :user
    create(:user_profile, user:)

    get contributions_profile_url(user)

    assert_redirected_to profile_path(user)
  end

  #############
  # Solutions #
  #############
  test "solutions redirects to profile page if user does not have solutions" do
    user = create :user
    create(:user_profile, user:)

    get solutions_profile_url(user)

    assert_redirected_to profile_path(user)
  end
end
