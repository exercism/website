require 'test_helper'

class User::Jiki::RetrieveInsiderIdsTest < ActiveSupport::TestCase
  test "includes active and active_lifetime users" do
    active = create(:user)
    active.data.update!(insiders_status: :active)

    lifetime = create(:user)
    lifetime.data.update!(insiders_status: :active_lifetime)

    other = create(:user)
    other.data.update!(insiders_status: :eligible)

    create(:user) # unset

    ids = User::Jiki::RetrieveInsiderIds.()

    assert_includes ids, active.id
    assert_includes ids, lifetime.id
    refute_includes ids, other.id
  end

  test "returns empty when no active users" do
    create(:user) # unset

    assert_empty User::Jiki::RetrieveInsiderIds.()
  end
end
