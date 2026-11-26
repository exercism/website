require 'test_helper'

class GetProfileToolTest < ActiveSupport::TestCase
  test "returns the profile summary" do
    user = create :user, handle: 'iHiD'
    create(:user_profile, user:)

    response = GetProfileTool.(handle: 'iHiD', server_context: nil)

    refute response.error?
    assert_equal SerializeProfileSummary.(user).to_json, response.content.first[:text]
  end

  test "errors for an unknown handle" do
    response = GetProfileTool.(handle: 'nobody', server_context: nil)

    assert response.error?
    assert_equal "No Exercism profile found for 'nobody'.", response.content.first[:text]
  end

  test "errors for a user without a profile" do
    create :user, handle: 'iHiD'

    response = GetProfileTool.(handle: 'iHiD', server_context: nil)

    assert response.error?
  end
end
