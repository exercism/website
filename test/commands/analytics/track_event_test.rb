require "test_helper"

class Analytics::TrackEventTest < ActiveSupport::TestCase
  teardown do
    Current.reset
  end

  def client
    @client ||= mock.tap { |client| Analytics.stubs(:client).returns(client) }
  end

  test "captures the event with the default properties" do
    user = create :user, locale: "hu"

    client.expects(:capture).with(
      distinct_id: user.id.to_s,
      event: "payment_prompt_shown",
      properties: {
        trigger: "beg_modal",
        membership_type: "free",
        locale: "hu",
        "$geoip_disable": true
      }
    )

    Analytics::TrackEvent.(user, "payment_prompt_shown", properties: { trigger: "beg_modal" })
  end

  test "records the membership type" do
    insider = create :user, insiders_status: :active
    lifetime_insider = create :user, insiders_status: :active_lifetime

    client.expects(:capture).with { |args| args[:properties][:membership_type] == "insider" }
    Analytics::TrackEvent.(insider, "site_visited")

    client.expects(:capture).with { |args| args[:properties][:membership_type] == "lifetime_insider" }
    Analytics::TrackEvent.(lifetime_insider, "site_visited")
  end

  test "falls back to the default locale" do
    user = create :user, locale: nil

    client.expects(:capture).with { |args| args[:properties][:locale] == "en" }

    Analytics::TrackEvent.(user, "site_visited")
  end

  test "sends the IP and user agent instead of disabling GeoIP" do
    user = create :user

    client.expects(:capture).with do |args|
      args[:properties][:"$ip"] == "86.41.10.20" &&
        args[:properties][:"$useragent"] == "Mozilla/5.0" &&
        !args[:properties].key?(:"$geoip_disable")
    end

    Analytics::TrackEvent.(user, "site_visited", user_ip: "86.41.10.20", user_agent: "Mozilla/5.0")
  end

  test "accepts string keys in the properties" do
    user = create :user

    client.expects(:capture).with { |args| args[:properties][:trigger] == "beg_modal" }

    Analytics::TrackEvent.(user, "payment_prompt_shown", properties: { "trigger" => "beg_modal" })
  end

  test "does nothing without a client" do
    Analytics.stubs(:client).returns(nil)

    assert_nil Analytics::TrackEvent.(create(:user), "site_visited")
  end

  test "defer copies the IP and user agent from Current" do
    user = create :user
    Current.ip_address = "86.41.10.20"
    Current.user_agent = "Mozilla/5.0"

    assert_enqueued_with(
      job: MandateJob,
      args: ["Analytics::TrackEvent", user, "site_visited", { user_ip: "86.41.10.20", user_agent: "Mozilla/5.0" }],
      queue: "analytics"
    ) do
      Analytics::TrackEvent.defer(user, "site_visited")
    end
  end

  test "defer keeps an IP passed explicitly" do
    user = create :user
    Current.ip_address = "86.41.10.20"

    assert_enqueued_with(
      job: MandateJob,
      args: ["Analytics::TrackEvent", user, "site_visited", { user_ip: nil, user_agent: nil }]
    ) do
      Analytics::TrackEvent.defer(user, "site_visited", user_ip: nil)
    end
  end

  test "sets the person properties with the user's activity" do
    user = create :user
    Analytics::DetermineActivityProperties.expects(:call).with(user).returns({ exercises_completed: 3 })

    client.expects(:capture).with do |args|
      args[:properties][:"$set"] == Analytics::IdentifyUser.person_properties(user).merge(exercises_completed: 3) &&
        !args[:properties].key?(:exercises_completed)
    end

    Analytics::TrackEvent.(user, "site_visited", set_person_properties: true)
  end

  test "snapshots the user's activity on the event" do
    user = create :user, created_at: Time.utc(2026, 11, 1)
    Analytics::DetermineActivityProperties.expects(:call).with(user).returns({ exercises_completed: 3 })

    client.expects(:capture).with do |args|
      args[:properties][:exercises_completed] == 3 &&
        args[:properties][:days_since_signup] == 10 &&
        !args[:properties].key?(:"$set")
    end

    travel_to(Time.utc(2026, 11, 11, 12)) do
      Analytics::TrackEvent.(user, "checkout_succeeded", snapshot_activity: true)
    end
  end

  test "doesn't look up activity unless asked" do
    Analytics::DetermineActivityProperties.expects(:call).never
    client.expects(:capture)

    Analytics::TrackEvent.(create(:user), "site_visited")
  end
end
