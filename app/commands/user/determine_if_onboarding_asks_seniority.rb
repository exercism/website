# The sign-up page asks people their level before they create an account.
# People who signed up before that page went live were never asked there,
# so the returning user modal asks them.
# Everyone who signs up afterwards has already been asked, so that modal
# leaves them alone, even if they skipped the question and have no seniority.
class User::DetermineIfOnboardingAsksSeniority
  include Mandate

  # Set this to the time the sign-up page that asks for seniority is deployed.
  # Users created before it are treated as having signed up without being asked.
  SIGN_UP_ASKS_SENIORITY_FROM = Time.utc(2026, 11, 7, 9, 59).freeze

  initialize_with :user

  def call = user.created_at < SIGN_UP_ASKS_SENIORITY_FROM
end
