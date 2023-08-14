class Forum::RetrieveThreads
  include Mandate

  initialize_with track: nil, count: 5, type: :latest do
    raise "Top topics for track is not available" if type == :top && track
  end

  def call
    topics[0, count].filter_map { |t| topic_to_thread(t) }
  rescue StandardError
    []
  end

  private
  memoize
  def topics
    cache_key = "forum/topics/#{type}/#{track&.slug}"
    Rails.cache.fetch(cache_key, expires_in: 2.hours) do
      if type == :latest
        track ?  latest_track_topics : latest_topics
      else
        top_topics
      end
    end
  end

  def top_topics = client.top_topics
  def latest_topics = client.latest_topics
  def latest_track_topics = client.category_latest_topics(category_slug: "programming/#{track.slug}")

  memoize
  def client = Exercism.discourse_client

  def topic_to_thread(topic)
    user_data = Rails.cache.fetch("forum/user_data/#{topic['last_poster_username']}") do
      client.user(topic['last_poster_username'])
    end

    user_username = user_data ? user_data['username'] : "Unknown"
    user_avatar = user_data ? "https://forum.exercism.org/#{user_data['avatar_template'].gsub('{size}', '120')}" : nil

    ForumThread.new(
      *topic.slice(*%w[id title image_url posts_count]).values,
      user_username,
      user_avatar
    )
  rescue StandardError
    nil
  end

  ForumThread = Struct.new(:id, :title, :image_url, :posts_count, :poster_username, :poster_avatar_url) do
    def url = "https://forum.exercism.org/t/topic/#{id}"
    def poster_avatar_url = self[:poster_avatar_url] || "https://assets.exercism.org/placeholders/user-avatar.svg"
  end
  private_constant :ForumThread
end
