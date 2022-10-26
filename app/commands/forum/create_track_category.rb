class Forum::CreateTrackCategory
  include Mandate

  initialize_with :track

  def call
    client.create_category({
      name: track.title,
      position:,
      parent_category_id: PROGRAMMING_CATEGORY_ID,
      color: COLOR,
      text_color: TEXT_COLOR
    })
  end

  def position
    next_category = track_categories.
      sort_by { |c| c["name"] }.
      drop_while { |c| c["name"].casecmp(track.title).negative? }.
      find { |c| c["position"] }

    next_category ? next_category["position"] : track_categories.last["position"] + 1
  end

  memoize
  def track_categories = client.categories({ parent_category_id: PROGRAMMING_CATEGORY_ID })

  private
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
