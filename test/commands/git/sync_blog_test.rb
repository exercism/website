require "test_helper"

class Git::SyncBlogTest < ActiveSupport::TestCase
  setup do
    TestHelpers.use_blog_test_repo!
  end

  test "creates missing posts" do
    create :user, handle: "iHiD"
    create :user, handle: "jonathandmiddleton"
    create :user, handle: "porkostumus"
    Git::SyncBlog.()

    assert_equal 1, BlogPost.count
    post = BlogPost.first
    assert_equal 'd925ec36-92dd-4bf6-be1d-969d192a4034', post.uuid
    assert_equal "updates", post.category
    assert_equal "sorry-for-the-wait", post.slug
    assert_equal "Sorry for the wait", post.title
    assert_equal "Our community is hard at work", post.marketing_copy
    assert_equal "Our community is hard at work so something.", post.description
  end

  test "updates existing posts" do
    create :user, handle: "iHiD"
    create :user, handle: "jonathandmiddleton"
    create :user, handle: "porkostumus"
    create :blog_post, uuid: "d925ec36-92dd-4bf6-be1d-969d192a4034",
      slug: "rlly",
      title: "Very wrong",
      marketing_copy: "Wrong",
      description: "Naughty"

    Git::SyncBlog.()

    assert_equal 1, BlogPost.count
    post = BlogPost.first
    assert_equal 'd925ec36-92dd-4bf6-be1d-969d192a4034', post.uuid
    assert_equal "updates", post.category
    assert_equal "sorry-for-the-wait", post.slug
    assert_equal "Sorry for the wait", post.title
    assert_equal "Our community is hard at work", post.marketing_copy
    assert_equal "Our community is hard at work so something.", post.description
  end

  test "creates missing stories" do
    create :user, handle: "iHiD"
    interviewer = create :user, handle: "jonathandmiddleton"
    interviewee = create :user, handle: "porkostumus"

    Git::SyncBlog.()

    assert_equal 1, CommunityStory.count
    story = CommunityStory.first
    assert_equal "e64c98c2-64a7-42ac-80ec-647561bbee7f", story.uuid
    assert_equal "why-i-love-tech", story.slug
    assert_equal "Why I love technology", story.title
    assert_equal "There is so much I love about technology.", story.blurb
    assert_equal Time.utc(2022, 10, 24, 12, 1), story.published_at
    assert_equal 90, story.length_in_minutes
    assert_equal "YoZ_aEw3Ep9", story.youtube_id
    assert_equal "https://test.org/thumbnail.png", story.thumbnail_url
    assert_equal "https://test.org/image.png", story.image_url
    assert_equal interviewer, story.interviewer
    assert_equal interviewee, story.interviewee
  end

  test "updates existing stories" do
    user = create :user, handle: "iHiD"
    interviewer = create :user, handle: "jonathandmiddleton"
    interviewee = create :user, handle: "porkostumus"

    create :community_story, uuid: "e64c98c2-64a7-42ac-80ec-647561bbee7f",
      interviewer: user, interviewee: user,
      slug: "old slug", title: "old title", blurb: "old blurb",
      published_at: Time.zone.now, length_in_minutes: 1,
      youtube_id: 'old youtube id', thumbnail_url: "old thumb", image_url: "old image"

    Git::SyncBlog.()

    assert_equal 1, CommunityStory.count
    story = CommunityStory.first
    assert_equal "e64c98c2-64a7-42ac-80ec-647561bbee7f", story.uuid
    assert_equal "why-i-love-tech", story.slug
    assert_equal "Why I love technology", story.title
    assert_equal "There is so much I love about technology.", story.blurb
    assert_equal Time.utc(2022, 10, 24, 12, 1), story.published_at
    assert_equal 90, story.length_in_minutes
    assert_equal "YoZ_aEw3Ep9", story.youtube_id
    assert_equal "https://test.org/thumbnail.png", story.thumbnail_url
    assert_equal "https://test.org/image.png", story.image_url
    assert_equal interviewer, story.interviewer
    assert_equal interviewee, story.interviewee
  end

  test "open issue for sync failure when not synced successfully" do
    create :user, handle: "iHiD"
    create :user, handle: "jonathandmiddleton"
    create :user, handle: "porkostumus"
    error = StandardError.new "Could not sync Blog"
    BlogPost.any_instance.stubs(:update!).raises(error)

    Github::Issue::OpenForBlogSyncFailure.expects(:call).with(error, Git::Blog.new.head_commit.oid)

    Git::SyncBlog.()
  end
end
