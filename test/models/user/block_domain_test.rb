require "test_helper"

class User::BlockDomainTest < ActiveSupport::TestCase
  test "blocked?" do
    user = create :user, email: 'test@invalid.org'

    refute User::BlockDomain.blocked?(user)

    create :user_block_domain, domain: 'invalid.org'
    assert User::BlockDomain.blocked?(user)
  end
end
