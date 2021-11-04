class Search::Solutions
  include Mandate

  initialize_with :query

  def call
    client.search(index: 'solutions', q: query, field: 'name')
  end

  private
  memoize
  def client
    Elasticsearch::Client.new url: ENV.fetch('OPENSEARCH_HOST', 'https://localhost:9200'),
      user: ENV.fetch('OPENSEARCH_USER', 'admin'),
      password: ENV.fetch('OPENSEARCH_PASSWORD', 'admin'),
      log: true,
      transport_options: {
        ssl: { verify: false }
      }
  end
end
