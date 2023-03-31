require 'test_helper'

class Tracks::ShowExternalTest < ActionDispatch::IntegrationTest
  test "the 6 features are shown" do
    track = create :track
    create(:concept_exercise, track:)

    get "/tracks/ruby"
    assert_select ".features-section .feature", 6
  end

  test "the about block is shown" do
    track = create :track
    create(:concept_exercise, track:)
    get "/tracks/ruby"

    assert_select ".about-section .c-react-wrapper-common-expander" do |elems|
      content = JSON.parse(elems.first.attributes["data-react-data"].value)['content']
      assert_includes content, 'Ruby is a dynamic, open source programming language'
    end
  end

  test "the snippet is shown" do
    track = create :track
    create(:concept_exercise, track:)
    get "/tracks/ruby"
    assert_select ".about-section code", text: /def self.hello/
  end
end
