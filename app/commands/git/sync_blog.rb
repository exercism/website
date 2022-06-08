module Git
  class SyncBlog
    include Mandate

    def call
      repo.update!

      repo.config[:posts].each do |data|
        create_or_update_post(data)
      end
    end

    private
    def create_or_update_post(data)
      author = User.find_by!(handle: data[:author_handle])
      attributes = {
        slug: data[:slug],
        author:,
        category: data[:category],
        title: data[:title],
        published_at: data[:published_at],
        description: data[:description],
        marketing_copy: data[:marketing_copy],
        image_url: data[:image_url],
        youtube_id: data[:youtube_id]
      }

      post = BlogPost.create_or_find_by!(
        uuid: data[:uuid]
      ) { |d| d.attributes = attributes }

      post.update!(attributes)
    rescue StandardError => e
      Github::Issue::OpenForBlogSyncFailure.(e, repo.head_commit.oid)
    end

    memoize
    def repo
      Git::Blog.new
    end
  end
end
