class Track::CreateForumCategory
  include Mandate

  initialize_with :track

  def call
    return if Rails.env.development?

    category = create_category!
    edit_first_post!(category)
  end

  private
  def create_category!
    client.create_category({
      name: track.title,
      slug: track.slug,
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
  def client = Exercism.discourse_client

  PROGRAMMING_CATEGORY_ID = 5
  COLOR = "0088CC".freeze
  TEXT_COLOR = "FFFFFF".freeze
  private_constant :PROGRAMMING_CATEGORY_ID, :COLOR, :TEXT_COLOR
end
