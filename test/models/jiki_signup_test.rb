require "test_helper"

class JikiSignupTest < ActiveSupport::TestCase
  test "validates presence of preferred_locale" do
    signup = build(:jiki_signup, preferred_locale: nil)
    refute signup.valid?
    assert_includes signup.errors[:preferred_locale], "can't be blank"
  end

  test "validates presence of preferred_programming_language" do
    signup = build(:jiki_signup, preferred_programming_language: nil)
    refute signup.valid?
    assert_includes signup.errors[:preferred_programming_language], "can't be blank"
  end

  test "validates programming language inclusion" do
    signup = build(:jiki_signup, preferred_programming_language: 'invalid')
    refute signup.valid?
    assert_includes signup.errors[:preferred_programming_language], "is not included in the list"
  end

  test "valid with correct attributes" do
    signup = build(:jiki_signup, preferred_locale: 'en', preferred_programming_language: 'javascript')
    assert signup.valid?
  end
end
