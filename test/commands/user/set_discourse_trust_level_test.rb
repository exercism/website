require "test_helper"

class User::SetDiscourseTrustLevelTest < ActiveSupport::TestCase
  test "works with rep >= 20" do
    user = create :user, reputation: 20
    discourse_user_id = 123

    json = { user: { id: discourse_user_id } }.to_json
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: json,
      headers: { "content-type": "application/json; charset=utf-8" })
    stub_request(:put, "https://forum.exercism.org/admin/users/#{discourse_user_id}/trust_level")

    User::SetDiscourseTrustLevel.(user)
  end

  test "noop with rep of 19" do
    user = create :user, reputation: 19

    User::SetDiscourseTrustLevel.(user)
  end

  test "noop if external user isn't found" do
    user = create :user, reputation: 20

    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_raise(DiscourseApi::NotFoundError)

    User::SetDiscourseTrustLevel.(user)
  end
end
