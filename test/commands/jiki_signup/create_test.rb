require 'test_helper'

class JikiSignup::CreateTest < ActiveSupport::TestCase
  test "creates new signup" do
    user = create(:user)

    signup = JikiSignup::Create.(user, 'en', 'javascript')

    assert_equal user, signup.user
    assert_equal 'en', signup.preferred_locale
    assert_equal 'javascript', signup.preferred_programming_language
  end

  test "updates existing signup" do
    user = create(:user)
    existing_signup = create(:jiki_signup, user:, preferred_locale: 'es', preferred_programming_language: 'python')

    signup = JikiSignup::Create.(user, 'en', 'javascript')

    assert_equal existing_signup.id, signup.id
    assert_equal 'en', signup.preferred_locale
    assert_equal 'javascript', signup.preferred_programming_language
  end
end
