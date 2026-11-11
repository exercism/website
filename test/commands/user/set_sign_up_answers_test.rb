require "test_helper"

class User::SetSignUpAnswersTest < ActiveSupport::TestCase
  test "sets the seniority and the track" do
    user = create :user, seniority: nil
    track = create :track, slug: "go"

    User::SetSignUpAnswers.(user, seniority: "junior", sign_up_track_slug: "go")

    assert_equal :junior, user.data.reload.seniority
    assert_equal track, user.data.sign_up_track
  end

  test "ignores an unknown seniority and an inactive track" do
    user = create :user, seniority: nil
    create :track, slug: "go", active: false

    User::SetSignUpAnswers.(user, seniority: "wizard", sign_up_track_slug: "go")

    assert_nil user.data.reload.seniority
    assert_nil user.data.sign_up_track
  end
end
