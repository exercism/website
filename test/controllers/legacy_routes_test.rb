require "test_helper"

class LegacyRoutesTest < ActionDispatch::IntegrationTest
  %w[licence license].each do |spelling|
    test "#{spelling}s/cc-sa-4" do
      get "/#{spelling}s/cc-sa-4"
      assert_redirected_to "http://test.exercism.org/docs/using/licenses/cc-by-nc-sa"
    end

    test "#{spelling}s/cc-by-nc-sa-4" do
      get "/#{spelling}s/cc-by-nc-sa-4"
      assert_redirected_to "http://test.exercism.org/docs/using/licenses/cc-by-nc-sa"
    end

    test "#{spelling}s/mit" do
      get "/#{spelling}s/mit"
      assert_redirected_to "http://test.exercism.org/docs/using/licenses/mit"
    end

    test "#{spelling}s/agpl" do
      get "/#{spelling}s/agpl"
      assert_redirected_to "http://test.exercism.org/docs/using/licenses/agpl"
    end
  end
end
