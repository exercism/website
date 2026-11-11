require "test_helper"

class Analytics::IdentifyUserTest < ActiveSupport::TestCase
  test "sets the person properties" do
    user = create :user, handle: "someone", locale: "hu", created_at: Time.utc(2024, 3, 2)
    client = mock
    Analytics.stubs(:client).returns(client)

    client.expects(:identify).with(
      distinct_id: user.id.to_s,
      properties: {
        handle: "someone",
        membership_type: "free",
        locale: "hu",
        signup_date: "2024-03-02",
        is_internal: false,
        "$geoip_disable": true
      }
    )

    Analytics::IdentifyUser.(user)
  end

  test "staff and admins are internal" do
    refute Analytics::IdentifyUser.person_properties(create(:user))[:is_internal]
    assert Analytics::IdentifyUser.person_properties(create(:user, roles: [:staff]))[:is_internal]
    assert Analytics::IdentifyUser.person_properties(create(:user, roles: [:admin]))[:is_internal]
  end

  test "does nothing without a client" do
    Analytics.stubs(:client).returns(nil)

    assert_nil Analytics::IdentifyUser.(create(:user))
  end
end
