require "test_helper"

class Document::CreateSearchIndexDocumentTest < ActiveSupport::TestCase
  test "the docs search index stays english" do
    doc = create :document, section: :using, slug: "settings", title: "Settings", blurb: "Your settings"
    doc.stubs(:markdown).returns("")

    with_published_translations({}) do
      publish_translated_metadata!(:hu, "docs", {
        "using:settings:title" => "Beállítások",
        "using:settings:blurb" => "A beállításaid"
      })

      I18n.with_locale(:hu) do
        document = Document::CreateSearchIndexDocument.(doc)
        assert_equal "Settings", document[:title]
        assert_equal "Your settings", document[:blurb]
      end
    end
  end
end
