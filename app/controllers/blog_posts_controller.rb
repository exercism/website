class BlogPostsController < ApplicationController
  def index
    @posts = BlogPost.published.ordered_by_recency.limit(13)
  end
end
