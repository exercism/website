require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "content_html renders correctly" do
    doc = create :document
    assert doc.content_html.starts_with?("<h2 id=\"h-running-tests\">Running Tests</h2>\n<p>Execute the tests with:</p>")
  end

  test "creating document enqueues job to sync document to search index" do
    assert_enqueued_with(job: MandateJob, args: ->(job_args) { job_args[0] == Document::SyncToSearchIndex.name }) do
      create :document
    end
  end

  test "updating document enqueues job to sync document to search index" do
    doc = create :document

    assert_enqueued_with(job: MandateJob, args: [Document::SyncToSearchIndex.name, doc]) do
      doc.update!(title: 'new-title')
    end
  end

  test "sorted scope sorts by position" do
    doc_1 = create :document, position: 3
    doc_2 = create :document, position: 1
    doc_3 = create :document, position: 2

    assert_equal [doc_2, doc_3, doc_1], Document.sorted
  end

  test "a docs page's title, blurb and nav title come from the docs catalog in a non-default locale" do
    apex = create :document, section: :using, slug: "APEX", title: "Using Exercism", blurb: "How to use Exercism"
    nested = create :document, section: :using, slug: "feedback/mentor", title: "Mentor feedback", blurb: "Get feedback"

    with_published_translations({}) do
      publish_translated_metadata!(:hu, "docs", {
        "using:APEX:title" => "Az Exercism használata",
        "using:APEX:blurb" => "Hogyan használd az Exercismet",
        "using:feedback/mentor:title" => "Mentori visszajelzés",
        "using:feedback/mentor:blurb" => "Kérj visszajelzést"
      })

      assert_equal "Using Exercism", apex.title
      assert_equal "Using Exercism", apex.nav_title

      I18n.with_locale(:hu) do
        assert_equal "Az Exercism használata", apex.title
        assert_equal "Hogyan használd az Exercismet", apex.blurb
        assert_equal "Az Exercism használata", apex.nav_title
        assert_equal "Mentori visszajelzés", nested.title
        assert_equal "Kérj visszajelzést", nested.blurb
      end
    end
  end

  test "a track doc's title and blurb come from the track's catalog in a non-default locale" do
    doc = create :document, :track, section: :tracks, slug: "installation", title: "Installing Ruby", blurb: "Install it"

    with_published_translations({}) do
      publish_translated_metadata!(:hu, "track", {
        "doc:installation:title" => "A Ruby telepítése",
        "doc:installation:blurb" => "Telepítsd"
      })

      assert_equal "Installing Ruby", doc.title

      I18n.with_locale(:hu) do
        assert_equal "A Ruby telepítése", doc.title
        assert_equal "Telepítsd", doc.blurb
      end
    end
  end
end
