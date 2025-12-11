require "test_helper"

class JikiControllerTest < ActionDispatch::IntegrationTest
  test "index: shows page for anonymous user" do
    get jiki_path

    assert_response :success
  end

  test "index: shows page for signed in user" do
    sign_in!

    get jiki_path

    assert_response :success
  end

  test "index: shows existing signup for signed in user" do
    sign_in!
    signup = create(:jiki_signup, user: @current_user)

    get jiki_path

    assert_response :success
    assert_equal signup, assigns(:existing_signup)
  end

  test "create: redirects to login for anonymous user" do
    post jiki_signup_path, params: { preferred_locale: 'en', preferred_programming_language: 'javascript' }

    assert_redirected_to jiki_path
  end

  test "create: creates signup for signed in user (HTML)" do
    sign_in!

    post jiki_signup_path, params: { preferred_locale: 'en', preferred_programming_language: 'javascript' }

    assert_redirected_to jiki_path
    signup = JikiSignup.find_by(user: @current_user)
    assert_equal 'en', signup.preferred_locale
    assert_equal 'javascript', signup.preferred_programming_language
  end

  test "create: creates signup and returns JSON for signed in user" do
    sign_in!

    post jiki_signup_path,
      params: { preferred_locale: 'en', preferred_programming_language: 'javascript' },
      as: :json

    assert_response :success

    json = JSON.parse(response.body)
    assert json['success']
    assert json['signup']

    signup = JikiSignup.find_by(user: @current_user)
    assert_equal 'en', signup.preferred_locale
    assert_equal 'javascript', signup.preferred_programming_language
  end

  test "create: updates existing signup for signed in user" do
    sign_in!
    create(:jiki_signup, user: @current_user, preferred_locale: 'es', preferred_programming_language: 'python')

    post jiki_signup_path, params: { preferred_locale: 'en', preferred_programming_language: 'javascript' }

    assert_redirected_to jiki_path
    signup = JikiSignup.find_by(user: @current_user)
    assert_equal 'en', signup.preferred_locale
    assert_equal 'javascript', signup.preferred_programming_language
  end
end
