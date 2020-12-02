require "test_helper"

class TracksControllerTest < ActionDispatch::IntegrationTest
  test "params get passed correctly" do
    ruby_1 = create :track, slug: :ruby_1, title: "Ruby #{SecureRandom.hex}"
    js = create :track, slug: :js, title: "JS #{SecureRandom.hex}"
    ruby_2 = create :track, slug: :ruby_2, title: "Ruby #{SecureRandom.hex}"

    user = create :user
    create :user_track, user: user, track: ruby_1
    create :user_track, user: user, track: js

    sign_in!(user)

    get tracks_url(
      criteria: "ruby",
      status: "joined"
    )
    assert_response :success

    # Assert only the track that matches the criteria
    # is retrieved and served.
    #
    # Is this going to work with React? If not,
    # should we have this as a system test instead?
    assert_includes @response.body, ruby_1.title
    refute_includes @response.body, js.title
    refute_includes @response.body, ruby_2.title
  end
end
