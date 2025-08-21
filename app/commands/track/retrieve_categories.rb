class Track::RetrieveCategories
  include Mandate

  CACHE_KEY = "Track::RetrieveCategories".freeze

  def call
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
      Track.order(:title).
        index_with { |track| track_category(track) }.
        select { |_, category| category.present? }
    end
  end

  private
  def track_category(track)
    topics = repo_topics.fetch(track.slug, [])
    (topics & CATEGORIES).first
  end

  memoize
  def repo_topics
    query = <<~GRAPHQL
      query ($endCursor: String) {
        search(
          query: "org:exercism archived:false topic:exercism-track"
          type: REPOSITORY
          first: 100
          after: $endCursor
        ) {
          nodes {
            ... on Repository {
              name
              repositoryTopics(first: 100) {
                nodes {
                  topic {
                    name
                  }
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    GRAPHQL

    response = Github::Graphql::ExecuteQuery.(query, [:search])
    response.flat_map do |nodes|
      nodes[:nodes].filter_map do |node|
        [node[:name], node.dig(:repositoryTopics, :nodes).map { |topic_node| topic_node.dig(:topic, :name) }]
      end
    end.sort.to_h
  end

  CACHE_EXPIRY = 1.day.freeze
  CATEGORIES = %w[wip-track unmaintained maintained maintained-autonomous maintained-solitary].freeze
  private_constant :CACHE_EXPIRY, :CATEGORIES
end
