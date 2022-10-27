class Track::CreateForumCategory
  include Mandate

  initialize_with :track

  def call
    category = create_category!
    edit_first_post!(category)
  end

  private
  def create_category!
    client.create_category({
      name: track.title,
      position:,
      parent_category_id: PROGRAMMING_CATEGORY_ID,
      color: COLOR,
      text_color: TEXT_COLOR
    })
  end

  def edit_first_post!(category)
    topic_id = category["topic_url"].split("/").last
    topic = client.topic(topic_id)
    post = topic.dig("post_stream", "posts").first
    content = "Welcome to the #{track.title} category. This is a space to ask any #{track.title} questions, discuss exercises from the Exercism #{track.title} track, or explore any other #{track.title}-related conversations!" # rubocop:disable Layout/LineLength
    client.edit_post(post["id"], content)
  end

  def position
    return 1 if track_categories.empty?
    return track_categories.last["position"] + 1 if track_categories.last["name"].casecmp(track.title).negative?

    track_categories.
      sort_by { |c| c["name"] }.
      drop_while { |c| c["name"].casecmp(track.title).negative? }.
      first["position"]
  end

  memoize
  def track_categories = client.categories({ parent_category_id: PROGRAMMING_CATEGORY_ID })

  memoize
  def client
    DiscourseApi::Client.new("https://forum.exercism.org").tap do |client|
      client.api_key = ENV.fetch("DISCOURSE_API_KEY", Exercism.secrets.discourse_api_key)
      client.api_username = ENV.fetch("DISCOURSE_API_USERNAME", "system")
    end
  end

  PROGRAMMING_CATEGORY_ID = 5
  COLOR = "0088CC".freeze
  TEXT_COLOR = "FFFFFF".freeze
  private_constant :PROGRAMMING_CATEGORY_ID, :COLOR, :TEXT_COLOR
end
