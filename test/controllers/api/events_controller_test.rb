require_relative './base_test_case'

class API::EventsControllerTest < API::BaseTestCase
  guard_incorrect_token! :api_events_path, method: :post

  test "tracks an allowed event" do
    setup_user

    Analytics::TrackBrowserEvent.expects(:call).with(
      @current_user,
      "checkout_submitted",
      properties: { "trigger" => "beg_modal", "payment_type" => "payment", "amount_in_cents" => 1600 }
    ).returns(true)

    post api_events_path, params: {
      event: "checkout_submitted",
      properties: { trigger: "beg_modal", payment_type: "payment", amount_in_cents: 1600, other: "dropped" }
    }, headers: @headers, as: :json

    assert_response :no_content
  end

  test "sends the event to PostHog in the background" do
    setup_user

    assert_enqueued_with(job: MandateJob) do
      post api_events_path, params: {
        event: "checkout_closed",
        properties: { trigger: "beg_modal" }
      }, headers: @headers, as: :json
    end

    assert_response :no_content
  end

  test "rejects an event that isn't allowed" do
    setup_user

    post api_events_path, params: { event: "user_signed_up" }, headers: @headers, as: :json

    assert_response :unprocessable_entity
  end

  test "ignores properties that aren't a hash" do
    setup_user

    Analytics::TrackBrowserEvent.expects(:call).with(@current_user, "assistant_limit_reached", properties: {}).returns(true)

    post api_events_path, params: { event: "assistant_limit_reached", properties: "nope" }, headers: @headers, as: :json

    assert_response :no_content
  end
end
