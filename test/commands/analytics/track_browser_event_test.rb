require "test_helper"

class Analytics::TrackBrowserEventTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
    @user = create :user
  end

  test "rejects events that aren't allowed" do
    Analytics::TrackEvent.expects(:defer).never

    refute Analytics::TrackBrowserEvent.(@user, "user_signed_up")
  end

  test "tracks checkout events with the checkout properties" do
    Analytics::TrackEvent.expects(:defer).with(
      @user,
      "checkout_submitted",
      properties: {
        trigger: "beg_modal",
        payment_type: "subscription",
        amount_in_cents: 1600,
        currency: "usd",
        interval: "month"
      }
    )

    assert Analytics::TrackBrowserEvent.(
      @user,
      "checkout_submitted",
      properties: { "trigger" => "beg_modal", "payment_type" => "subscription", "amount_in_cents" => "1600" }
    )
  end

  test "one-off payments have no interval" do
    Analytics::TrackEvent.expects(:defer).with(
      @user,
      "checkout_closed",
      properties: { trigger: "donations_page", payment_type: "payment", amount_in_cents: 3200, currency: "usd" }
    )

    Analytics::TrackBrowserEvent.(
      @user,
      "checkout_closed",
      properties: { "trigger" => "donations_page", "payment_type" => "payment", "amount_in_cents" => 3200 }
    )
  end

  test "drops values that aren't recognised" do
    Analytics::TrackEvent.expects(:defer).with(@user, "checkout_closed", properties: {})

    Analytics::TrackBrowserEvent.(
      @user,
      "checkout_closed",
      properties: { "trigger" => "somewhere", "payment_type" => "crypto", "amount_in_cents" => "lots", "other" => "x" }
    )
  end

  test "checkout_failed records the error and decline codes" do
    Analytics::TrackEvent.expects(:defer).with(
      @user,
      "checkout_failed",
      properties: {
        trigger: "insiders_page",
        payment_type: "subscription",
        amount_in_cents: 1000,
        currency: "usd",
        interval: "month",
        error_code: "card_declined",
        decline_code: "insufficient_funds"
      }
    )

    Analytics::TrackBrowserEvent.(
      @user,
      "checkout_failed",
      properties: {
        "trigger" => "insiders_page",
        "payment_type" => "subscription",
        "amount_in_cents" => 1000,
        "error_code" => "card_declined",
        "decline_code" => "insufficient_funds"
      }
    )
  end

  test "payment_prompt_shown is sent once per user per trigger per day" do
    Analytics::TrackEvent.expects(:defer).with(@user, "payment_prompt_shown", properties: { trigger: "beg_modal" }).twice
    Analytics::TrackEvent.expects(:defer).with(@user, "payment_prompt_shown", properties: { trigger: "footer_form" }).once

    travel_to Time.utc(2026, 11, 11, 23, 0) do
      assert Analytics::TrackBrowserEvent.(@user, "payment_prompt_shown", properties: { "trigger" => "beg_modal" })
      assert Analytics::TrackBrowserEvent.(@user, "payment_prompt_shown", properties: { "trigger" => "beg_modal" })
      Analytics::TrackBrowserEvent.(@user, "payment_prompt_shown", properties: { "trigger" => "footer_form" })
    end

    travel_to Time.utc(2026, 11, 12, 1, 0) do
      Analytics::TrackBrowserEvent.(@user, "payment_prompt_shown", properties: { "trigger" => "beg_modal" })
    end
  end

  test "payment_prompt_shown is counted separately for each user" do
    other = create :user
    Analytics::TrackEvent.expects(:defer).with(@user, "payment_prompt_shown", properties: { trigger: "beg_modal" })
    Analytics::TrackEvent.expects(:defer).with(other, "payment_prompt_shown", properties: { trigger: "beg_modal" })

    Analytics::TrackBrowserEvent.(@user, "payment_prompt_shown", properties: { "trigger" => "beg_modal" })
    Analytics::TrackBrowserEvent.(other, "payment_prompt_shown", properties: { "trigger" => "beg_modal" })
  end

  test "assistant_limit_reached is sent once per user per day" do
    Analytics::TrackEvent.expects(:defer).with(@user, "assistant_limit_reached", properties: {}).once

    2.times { Analytics::TrackBrowserEvent.(@user, "assistant_limit_reached") }
  end
end
