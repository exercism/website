require "test_helper"

class DiscourseControllerTest < ActionDispatch::IntegrationTest
  test "sso redirects" do
    user = create :user
    resulting_url = "/foo/bar"

    sso = mock
    sso.expects(:email=).with(user.email)
    sso.expects(:name=).with(user.name)
    sso.expects(:username=).with(user.handle)
    sso.expects(:external_id=).with(user.id)
    sso.expects(:avatar_url=).with(user.avatar_url)
    sso.expects(:bio=).with(user.bio)
    sso.expects(:sso_secret=).with(Exercism.secrets.discourse_oauth_secret)

    sso.expects(:to_url).returns(resulting_url)
    DiscourseApi::SingleSignOn.expects(:parse).with("who=why", Exercism.secrets.discourse_oauth_secret).returns(sso)
    User::SetDiscourseGroups.expects(:defer).with(user, wait: 30.seconds)

    sign_in!(user)

    get discourse_sso_url(who: "why")

    assert_redirected_to resulting_url
  end

  test "awards discourser badge" do
    user = create :user

    refute_includes user.reload.badges.map(&:class), Badges::DiscourserBadge

    resulting_url = "/foo/bar"

    sso = mock
    sso.expects(:email=).with(user.email)
    sso.expects(:name=).with(user.name)
    sso.expects(:username=).with(user.handle)
    sso.expects(:external_id=).with(user.id)
    sso.expects(:avatar_url=).with(user.avatar_url)
    sso.expects(:bio=).with(user.bio)
    sso.expects(:sso_secret=).with(Exercism.secrets.discourse_oauth_secret)

    sso.expects(:to_url).returns(resulting_url)
    DiscourseApi::SingleSignOn.expects(:parse).with("who=why", Exercism.secrets.discourse_oauth_secret).returns(sso)
    stub_request(:get, "https://forum.exercism.org/users/by-external/#{user.id}").to_return(status: 200, body: { user: { id: 123 } }.to_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:get, "https://forum.exercism.org/groups/insiders.json").to_return(status: 200, body: { group: { id: 1 } }.to_json, headers: { "content-type": "application/json; charset=utf-8" }) # rubocop:disable Layout/LineLength
    stub_request(:delete, "https://forum.exercism.org/admin/groups/1/members.json?user_ids=123")

    sign_in!(user)

    Bullet.profile do
      get discourse_sso_url(who: "why")
      perform_enqueued_jobs
    end

    assert_includes user.reload.badges.map(&:class), Badges::DiscourserBadge
  end
end
