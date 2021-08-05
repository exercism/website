require "test_helper"

class RedirectsControllerTest < ActionDispatch::IntegrationTest
  %i[installation learning resources tests].each do |doc|
    test "docs: #{doc}" do
      track = create :track
      get "/tracks/#{track.slug}/#{doc}"
      assert_redirected_to track_doc_path(track.slug, doc)
    end
  end
end
