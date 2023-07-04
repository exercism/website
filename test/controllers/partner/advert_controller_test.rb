require "test_helper"

class Partner::AdvertControllerTest < ActionDispatch::IntegrationTest
  test "click logs and redirects" do
    freeze_time do
      user = create :user
      advert = create :advert
      impression_uuid = SecureRandom.uuid

      Partner::LogAdvertClick.expects(:defer).with(
        advert, user, Time.current, impression_uuid
      )

      sign_in!(user)
      get redirect_advert_url(advert.uuid, impression_uuid:)

      assert_redirected_to advert.url
    end
  end
end
