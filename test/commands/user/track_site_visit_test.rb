require "test_helper"

class User::TrackSiteVisitTest < ActiveSupport::TestCase
  test "records today and sends site_visited on a first visit" do
    user = create :user, last_visited_on: nil

    Analytics::TrackEvent.expects(:defer).with(user, "site_visited")

    User::TrackSiteVisit.(user)

    assert_equal Time.current.utc.to_date, user.data.reload.last_visited_on
  end

  test "records today and sends site_visited when last visited before today" do
    user = create :user, last_visited_on: Time.current.utc.to_date - 1.day

    Analytics::TrackEvent.expects(:defer).with(user, "site_visited")

    User::TrackSiteVisit.(user)

    assert_equal Time.current.utc.to_date, user.data.reload.last_visited_on
  end

  test "does nothing when already visited today" do
    user = create :user, last_visited_on: Time.current.utc.to_date

    Analytics::TrackEvent.expects(:defer).never

    User::TrackSiteVisit.(user)
  end

  test "does nothing when another request has already claimed today" do
    user = create :user, last_visited_on: Time.current.utc.to_date - 1.day
    User::Data.where(user_id: user.id).update_all(last_visited_on: Time.current.utc.to_date)

    Analytics::TrackEvent.expects(:defer).never

    User::TrackSiteVisit.(user)
  end

  test "uses the UTC date" do
    user = create :user, last_visited_on: nil

    Analytics::TrackEvent.expects(:defer).with(user, "site_visited")

    # 11pm UTC on 2 June is already 3 June in Auckland.
    travel_to Time.utc(2026, 6, 2, 23, 0) do
      Time.use_zone("Auckland") { User::TrackSiteVisit.(user) }
    end

    assert_equal Date.new(2026, 6, 2), user.data.reload.last_visited_on
  end
end
