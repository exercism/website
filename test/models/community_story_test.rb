require "test_helper"

class CommunityStoryTest < ActiveSupport::TestCase
  test "scope: published" do
    freeze_time do
      story_1 = create :community_story, published_at: Time.current - 1.second
      create :community_story, published_at: Time.current + 1.second
      story_3 = create :community_story, published_at: Time.current

      assert_equal [story_1, story_3], CommunityStory.published
    end
  end

  test "scope: scheduled" do
    freeze_time do
      create :community_story, published_at: Time.current - 1.minute
      story_2 = create :community_story, published_at: Time.current + 1.minute
      create :community_story, published_at: Time.current

      assert_equal [story_2], CommunityStory.scheduled
    end
  end

  test "scope: ordered_by_recency" do
    story_1 = create :community_story, published_at: Time.current - 1.second
    story_2 = create :community_story, published_at: Time.current + 1.second
    story_3 = create :community_story, published_at: Time.current

    assert_equal [story_2, story_3, story_1], CommunityStory.ordered_by_recency
  end

  test "to_param" do
    story = create :community_story
    assert_equal story.slug, story.to_param
  end

  test "content_html" do
    TestHelpers.use_blog_test_repo!
    story = create :community_story, slug: 'why-i-love-tech'

    expected = "<p>Because it's great!</p>\n"
    assert_equal expected, story.content_html
  end

  test "a community story's title and blurb come from the blog catalog in a non-default locale" do
    story = create :community_story, slug: "dont-be-productive"

    with_published_translations({}) do
      publish_translated_metadata!(:hu, "blog", {
        "story:dont-be-productive:title" => "Ne légy produktív",
        "story:dont-be-productive:blurb" => "Próbálj nem produktív lenni"
      })

      assert_equal "Don't be productive", story.title

      I18n.with_locale(:hu) do
        assert_equal "Ne légy produktív", story.title
        assert_equal "Próbálj nem produktív lenni", story.blurb
      end
    end
  end
end
