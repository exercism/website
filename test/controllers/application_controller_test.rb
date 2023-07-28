require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "rescues MimeNegotiation::InvalidType error" do
    get "/",
      headers: {
        accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*;q=0.8,application/signed-exchange;v=b3"
      }

    assert_equal 400, response.status
  end

  test "visiting HTML page updates last_visited_on date" do
    user = create :user, last_visited_on: nil

    sign_in!(user)
    get dashboard_path

    assert_equal Time.zone.today, user.reload.last_visited_on
  end

  test "calling API does not update last_visited_on date" do
    user = create :user, last_visited_on: nil

    sign_in!(user)
    get api_tracks_path, headers: @headers, as: :json

    assert_nil user.last_visited_on
  end
end
