require "test_helper"

class Partner::AdvertControllerTest < ActionDispatch::IntegrationTest
  test "click logs and redirects" do
    freeze_time do
      user = create :user
      advert = create :advert
      impression_uuid = SecureRandom.uuid

      sign_in!(user)
      get partner_advert_click_url(advert.id)

      Partner::LogAdvertClick.expects(:defer).with(
        advert, user, '127.0.0.1',
        Time.current, impression_uuid
      )

      assert_response :ok
    end
  end
end
