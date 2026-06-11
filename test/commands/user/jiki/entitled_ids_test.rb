require 'test_helper'

class User::Jiki::EntitledIdsTest < ActiveSupport::TestCase
  test "insiders includes active and active_lifetime users" do
    active = create(:user)
    active.data.update!(insiders_status: :active)

    lifetime = create(:user)
    lifetime.data.update!(insiders_status: :active_lifetime)

    other = create(:user)
    other.data.update!(insiders_status: :eligible)

    create(:user) # unset

    ids = User::Jiki::EntitledIds.insiders

    assert_includes ids, active.id
    assert_includes ids, lifetime.id
    refute_includes ids, other.id
  end

  test "insiders returns empty when no active users" do
    create(:user) # unset

    assert_empty User::Jiki::EntitledIds.insiders
  end

  test "bootcamp_members includes bootcamp_attendee" do
    user = create(:user)
    user.data.update!(bootcamp_attendee: true)

    assert_includes User::Jiki::EntitledIds.bootcamp_members, user.id
  end

  test "bootcamp_members includes bootcamp_mentor" do
    user = create(:user, bootcamp_mentor: true)

    assert_includes User::Jiki::EntitledIds.bootcamp_members, user.id
  end

  test "bootcamp_members includes users enrolled on part 1" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true)

    assert_includes User::Jiki::EntitledIds.bootcamp_members, user.id
  end

  test "bootcamp_members includes users enrolled on part 2" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_2: true)

    assert_includes User::Jiki::EntitledIds.bootcamp_members, user.id
  end

  test "bootcamp_members deduplicates users matching multiple criteria" do
    user = create(:user, bootcamp_mentor: true)
    user.data.update!(bootcamp_attendee: true)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true, enrolled_on_part_2: true)

    ids = User::Jiki::EntitledIds.bootcamp_members

    assert_equal 1, ids.count(user.id)
  end

  test "bootcamp_members excludes users with no bootcamp data" do
    create(:user)

    assert_empty User::Jiki::EntitledIds.bootcamp_members
  end
end
