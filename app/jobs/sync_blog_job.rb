class SyncBlogJob < ApplicationJob
  queue_as :default

  def perform
    Git::SyncBlog.()
  end
end
