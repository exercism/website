require_relative "../react_component_test_case"

class ReactComponents::Settings::GithubSyncerFormTest < ReactComponentTestCase
  test "a user without GitHub linked gets a link that returns to the syncer page" do
    user = create :user
    component = ReactComponents::Settings::GithubSyncerForm.new
    component.stubs(current_user: user)

    props = props_for(component)

    refute props[:is_github_linked]
    assert_nil props[:github_username]
    assert_equal "/users/auth/github?origin=%2Fsettings%2Fgithub_syncer", props[:links][:link_github]
  end

  test "a user with GitHub linked gets the username" do
    user = create :user, provider: "github", uid: "12345"
    user.data.update!(github_username: "gh-user")
    component = ReactComponents::Settings::GithubSyncerForm.new
    component.stubs(current_user: user)

    props = props_for(component)

    assert props[:is_github_linked]
    assert_equal "gh-user", props[:github_username]
  end

  private
  def props_for(component)
    node = Nokogiri::HTML.fragment(component.to_s).at_css("[data-react-data]")
    JSON.parse(node["data-react-data"], symbolize_names: true)
  end
end
