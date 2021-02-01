require 'test_helper'

class Tracks::ShowExternalTest < ActionDispatch::IntegrationTest
  test "the 6 features are shown" do
    create :track
    get "/tracks/ruby"
    assert_select ".features-section .feature", 6
  end

  test "the about block is shown" do
    create :track
    get "/tracks/ruby"
    assert_select ".about-section", text: /Ruby is a dynamic, open source programming language/
  end

  test "the snippet is shown" do
    create :track
    get "/tracks/ruby"
    assert_select ".about-section code", text: /def self.hello/
  end
end
