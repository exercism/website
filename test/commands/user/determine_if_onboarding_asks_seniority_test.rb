require "test_helper"

class User::DetermineIfOnboardingAsksSeniorityTest < ActiveSupport::TestCase
  test "true for a user created before the sign-up page asked for seniority" do
    user = create :user, created_at: cutoff - 1.second

    assert User::DetermineIfOnboardingAsksSeniority.(user)
  end

  test "false for a user created when the sign-up page started asking" do
    user = create :user, created_at: cutoff

    refute User::DetermineIfOnboardingAsksSeniority.(user)
  end

  test "false for a user created after the sign-up page started asking" do
    user = create :user, seniority: nil, created_at: cutoff + 1.day

    refute User::DetermineIfOnboardingAsksSeniority.(user)
  end

  private
  def cutoff = User::DetermineIfOnboardingAsksSeniority::SIGN_UP_ASKS_SENIORITY_FROM
end
