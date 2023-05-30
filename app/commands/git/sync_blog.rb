class Git::SyncBlog
  include Mandate

  queue_as :default

  def call
    repo.update!

    repo.config[:posts].to_a.each do |data|
      create_or_update_post(data)
    end

    repo.config[:stories].to_a.each do |data|
      create_or_update_story(data)
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

    post = BlogPost.find_create_or_find_by!(uuid: data[:uuid]) do |d|
      d.attributes = attributes
    end

    post.update!(attributes)
  rescue StandardError => e
    Github::Issue::OpenForBlogSyncFailure.(e, repo.head_commit.oid)
  end

  def create_or_update_story(data)
    interviewer = User.find_by!(handle: data[:interviewer_handle])
    interviewee = User.find_by!(handle: data[:interviewee_handle])
    attributes = {
      interviewer:,
      interviewee:,
      slug: data[:slug],
      title: data[:title],
      blurb: data[:blurb],
      published_at: data[:published_at],
      thumbnail_url: data[:thumbnail_url],
      image_url: data[:image_url],
      youtube_id: data[:youtube_id],
      length_in_minutes: data[:length_in_minutes]
    }

    story = CommunityStory.find_create_or_find_by!(uuid: data[:uuid]) do |d|
      d.attributes = attributes
    end

    story.update!(attributes)
  rescue StandardError => e
    Github::Issue::OpenForBlogSyncFailure.(e, repo.head_commit.oid)
  end

  memoize
  def repo
    Git::Blog.new
  end
end
