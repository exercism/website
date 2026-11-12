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
end
