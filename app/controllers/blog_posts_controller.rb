class BlogPostsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @posts = BlogPost.published.ordered_by_recency.limit(13)
  end

  def show
    @post = BlogPost.published.find(params[:id])
    @other_posts = BlogPost.published.ordered_by_recency.where.not(id: @post.id).limit(3)
  end
end
