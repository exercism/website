class BlogPostsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @posts = BlogPost.published.ordered_by_recency.includes(:author).page(params[:page]).per(13)

    respond_to do |format|
      format.html
      format.rss do
        headers['Content-Disposition'] = "inline"
        render type: "application/rss"
      end
    end
  end

  def show
    @post = BlogPost.published.find(params[:id])
    @other_posts = BlogPost.published.ordered_by_recency.includes(:author).where.not(id: @post.id).limit(6)
  end
end
