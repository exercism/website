require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "rescues MimeNegotiation::InvalidType error" do
    get "/",
      headers: {
        accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*;q=0.8,application/signed-exchange;v=b3"
      }

    assert_equal 400, response.status
  end
end
