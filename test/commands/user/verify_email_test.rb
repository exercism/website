require "test_helper"

class User::VerifyEmailTest < ActiveSupport::TestCase
  %w[valid neutral].each do |status|
    test "updates user's email status to verified when verify result is #{status}" do
      user = create :user, email: 'test@example.org', email_status: :unverified

      stub_request(:get, "https://api.sparkpost.com/api/v1/recipient-validation/single/test@example.org").
        to_return(status: 200, body: { results: { result: status } }.to_json, headers: { 'Content-Type': 'application/json' })

      User::VerifyEmail.(user)

      assert_equal :verified, user.email_status
    end
  end

  %w[risky undeliverable typo].each do |status|
    test "updates user's email status to invalid when verify result is #{status}" do
      user = create :user, email: 'test@example.org', email_status: :unverified

      stub_request(:get, "https://api.sparkpost.com/api/v1/recipient-validation/single/test@example.org").
        to_return(status: 200, body: { results: { result: status } }.to_json, headers: { 'Content-Type': 'application/json' })

      User::VerifyEmail.(user)

      assert_equal :invalid, user.email_status
    end
  end
end
