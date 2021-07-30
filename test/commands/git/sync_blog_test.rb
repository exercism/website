require "test_helper"

class Git::SyncBlogTest < ActiveSupport::TestCase
  setup do
    TestHelpers.use_blog_test_repo!
  end

  test "creates missing posts" do
    create :user, handle: "iHiD"
    Git::SyncBlog.()

    assert_equal 1, BlogPost.count
    post = BlogPost.first
    assert_equal 'd925ec36-92dd-4bf6-be1d-969d192a4034', post.uuid
    assert_equal "updates", post.category
    assert_equal "sorry-for-the-wait", post.slug
    assert_equal "Sorry for the wait", post.title
    assert_equal "Our community is hard at work", post.marketing_copy
  end

  test "updates existing posts" do
    create :user, handle: "iHiD"
    create :blog_post, uuid: "d925ec36-92dd-4bf6-be1d-969d192a4034",
                       slug: "rlly",
                       title: "Very wrong",
                       marketing_copy: "Wrong"

    Git::SyncBlog.()

    assert_equal 1, BlogPost.count
    post = BlogPost.first
    assert_equal 'd925ec36-92dd-4bf6-be1d-969d192a4034', post.uuid
    assert_equal "updates", post.category
    assert_equal "sorry-for-the-wait", post.slug
    assert_equal "Sorry for the wait", post.title
    assert_equal "Our community is hard at work", post.marketing_copy
  end

  test "open issue for sync failure when not synced successfully" do
    create :user, handle: "iHiD"
    error = StandardError.new "Could not sync Blog"
    BlogPost.any_instance.stubs(:update!).raises(error)

    Github::Issue::OpenForBlogSyncFailure.expects(:call).with(error, Git::Blog.new.head_commit.oid)

    Git::SyncBlog.()
  end
end
