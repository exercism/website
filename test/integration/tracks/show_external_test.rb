require 'test_helper'

class Tracks::ShowExternalTest < ActionDispatch::IntegrationTest
  test "the 6 features are shown" do
    create :track, slug: 'csharp'
    get "/tracks/csharp"
    assert_select ".features-section .feature", 6
  end

  test "the about block is shown" do
    create :track, slug: 'csharp'
    get "/tracks/csharp"
    assert_select ".about-section", text: /C# is a multi-paradigm, statically-typed programming language/
  end

  test "the snippet is shown" do
    create :track, slug: 'csharp'
    get "/tracks/csharp"
    assert_select ".about-section code", text: /class HelloWorld/
  end
end
