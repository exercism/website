require "test_helper"

class CommunityStory::SearchTest < ActiveSupport::TestCase
  test "no options returns only stories published before now, order by most recent" do
    story_1 = create :community_story, published_at: Time.current - 1.day
    story_2 = create :community_story, published_at: Time.current - 5.days
    story_3 = create :community_story, published_at: Time.current - 3.days
    create :community_story, published_at: Time.current + 2.hours

    stories = CommunityStory::Search.()

    assert_equal [story_1, story_3, story_2], stories
  end
end
