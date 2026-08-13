require "test_helper"

class SPI::ProfileImageDataControllerTest < ActionDispatch::IntegrationTest
  test "returns the data needed to draw the image" do
    user = create :user, handle: 'ihid', name: 'Jeremy Walker', flair: :founder
    create(:user_profile, user:)

    get "/spi/profile_image_data/ihid"

    assert_response :ok
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal 'ihid', actual[:header][:handle]
    assert_equal 'Jeremy Walker', actual[:header][:name]
    assert_equal 'founder', actual[:header][:flair]
    assert_equal(%w[publishing mentoring authoring building maintaining other],
      actual[:categories].map { |category| category[:id] })
  end

  # The generator calls this over the internal ALB with no session.
  test "is reachable without authentication" do
    user = create :user
    create(:user_profile, user:)

    get "/spi/profile_image_data/#{user.handle}"

    assert_response :ok
  end

  # SPI::BaseController has no rescue_from, so this propagates to a 404 in production.
  test "raises for a user that doesn't exist" do
    assert_raises ActiveRecord::RecordNotFound do
      get "/spi/profile_image_data/nope"
    end
  end

  test "raises for a user with no profile" do
    user = create :user

    assert_raises ActiveRecord::RecordNotFound do
      get "/spi/profile_image_data/#{user.handle}"
    end
  end
end
