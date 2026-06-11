require 'test_helper'

class User::JikiStatusesTest < ActiveSupport::TestCase
  test "is_insider true for active and active_lifetime" do
    active = create(:user)
    active.data.update!(insiders_status: :active)

    lifetime = create(:user)
    lifetime.data.update!(insiders_status: :active_lifetime)

    statuses = User::JikiStatuses.([active.id, lifetime.id])

    assert statuses[0][:is_insider]
    assert statuses[1][:is_insider]
  end

  test "is_insider false for non-active statuses" do
    %i[unset ineligible eligible eligible_lifetime].each do |status|
      user = create(:user)
      user.data.update!(insiders_status: status)

      statuses = User::JikiStatuses.([user.id])

      refute statuses[0][:is_insider], "expected #{status} to not be insider"
    end
  end

  test "is_bootcamp_member true for bootcamp_attendee" do
    user = create(:user)
    user.data.update!(bootcamp_attendee: true)

    statuses = User::JikiStatuses.([user.id])

    assert statuses[0][:is_bootcamp_member]
  end

  test "is_bootcamp_member true for bootcamp_mentor" do
    user = create(:user, bootcamp_mentor: true)

    statuses = User::JikiStatuses.([user.id])

    assert statuses[0][:is_bootcamp_member]
  end

  test "is_bootcamp_member true when enrolled on part 1" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_1: true)

    statuses = User::JikiStatuses.([user.id])

    assert statuses[0][:is_bootcamp_member]
  end

  test "is_bootcamp_member true when enrolled on part 2" do
    user = create(:user)
    create(:user_bootcamp_data, user:, enrolled_on_part_2: true)

    statuses = User::JikiStatuses.([user.id])

    assert statuses[0][:is_bootcamp_member]
  end

  test "is_bootcamp_member false when no bootcamp data and not mentor/attendee" do
    user = create(:user)

    statuses = User::JikiStatuses.([user.id])

    refute statuses[0][:is_bootcamp_member]
  end

  test "returns false/false for unknown ids" do
    statuses = User::JikiStatuses.([999_999])

    assert_equal(
      [{ exercism_id: 999_999, is_insider: false, is_bootcamp_member: false }],
      statuses
    )
  end

  test "preserves input order" do
    a = create(:user)
    b = create(:user)
    c = create(:user)

    statuses = User::JikiStatuses.([c.id, a.id, b.id])

    assert_equal([c.id, a.id, b.id], statuses.map { _1[:exercism_id] })
  end

  test "handles mixed batch with unknown ids" do
    user = create(:user)
    user.data.update!(insiders_status: :active)

    statuses = User::JikiStatuses.([user.id, 999_999])

    assert_equal user.id, statuses[0][:exercism_id]
    assert statuses[0][:is_insider]
    assert_equal 999_999, statuses[1][:exercism_id]
    refute statuses[1][:is_insider]
  end

  test "handles empty input" do
    assert_empty User::JikiStatuses.([])
  end
end
