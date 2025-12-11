class JikiSignup::Create
  include Mandate

  initialize_with :user, :preferred_locale, :preferred_programming_language

  def call
    signup = JikiSignup.find_or_initialize_by(user:)
    signup.preferred_locale = preferred_locale
    signup.preferred_programming_language = preferred_programming_language
    signup.save!

    signup
  end
end
