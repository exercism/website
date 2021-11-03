class Search::Solutions
  include Mandate

  initialize_with :query

  def call
    client.search(index: 'solutions', q: query, field: 'name')
  end

  private
  memoize
  def client
    Elasticsearch::Client.new url: 'https://localhost:9200',
      user: 'admin',
      password: 'admin',
      log: true,
      transport_options: {
        ssl: { verify: false }
      }
  end
end
