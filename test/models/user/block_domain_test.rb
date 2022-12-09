require "test_helper"

class User::BlockDomainTest < ActiveSupport::TestCase
  test "blocked? with user" do
    user = create :user, email: 'test@invalid.org'

    refute User::BlockDomain.blocked?(user:)

    create :user_block_domain, domain: 'invalid.org'
    assert User::BlockDomain.blocked?(user:)
  end

  test "blocked? with email" do
    email = 'test@invalid.org'

    refute User::BlockDomain.blocked?(email:)

    create :user_block_domain, domain: 'invalid.org'
    assert User::BlockDomain.blocked?(email:)
  end

  test "raises when called without email or user" do
    assert_raises do
      User::BlockDomain.blocked?
    end
  end
end
