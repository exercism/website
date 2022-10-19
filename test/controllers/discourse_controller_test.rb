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

    sign_in!(user)
    get discourse_sso_url(who: "why")

    assert_redirected_to resulting_url
  end
end
