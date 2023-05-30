require "test_helper"

class User::VerifyEmailTest < ActiveSupport::TestCase
  %w[valid neutral].each do |status|
    test "updates user's email status to verified when verify result is #{status}" do
      user = create :user, email: 'test@example.org'
      user.update(email_status: :unverified)

      stub_request(:get, "https://api.sparkpost.com/api/v1/recipient-validation/single/test@example.org").
        with(headers: { Authorization: Exercism.secrets.sparkpost_api_key }).
        to_return(status: 200, body: { results: { result: status } }.to_json, headers: { 'Content-Type': 'application/json' })

      User::VerifyEmail.(user)

      assert_equal :verified, user.email_status
    end
  end

  %w[risky undeliverable typo].each do |status|
    test "updates user's email status to invalid when verify result is #{status}" do
      user = create :user, email: 'test@example.org'
      user.update(email_status: :unverified)

      stub_request(:get, "https://api.sparkpost.com/api/v1/recipient-validation/single/test@example.org").
        with(headers: { Authorization: Exercism.secrets.sparkpost_api_key }).
        to_return(status: 200, body: { results: { result: status } }.to_json, headers: { 'Content-Type': 'application/json' })

      User::VerifyEmail.(user)

      assert_equal :invalid, user.email_status
    end
  end

  %i[verified invalid].each do |email_status|
    test "does not verify email when current email status is #{email_status}" do
      created_at = Time.current - 2.days
      user = create(:user, created_at:)
      user.update(email_status:)

      User::VerifyEmail.(user)

      assert_equal created_at, user.created_at
    end
  end
end
