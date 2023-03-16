require "test_helper"

class Maintaining::TracksControllerTest < ActionDispatch::IntegrationTest
  test "show - redirects non maintainers" do
    track = create :track
    user = create :user
    sign_in!(user)

    get maintaining_track_path(track)
    assert_redirected_to root_path
  end

  test "show - shows for maintainer" do
    track = create :track
    user = create :user, :maintainer
    sign_in!(user)

    Tooling::RetrieveSha.stubs(:call).returns({ image_details: [] })

    get maintaining_track_path(track)
    assert_response :ok
  end
end
