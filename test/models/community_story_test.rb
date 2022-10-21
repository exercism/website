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
end
