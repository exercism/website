module Git
  class Concept
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    initialize_with :track_slug, :concept_slug, :git_sha

    memoize
    def data
      resp = RestClient.get(url_for(:data))
      data = JSON.parse(resp.body)
      OpenStruct.new(data['concept']).tap do |concept|
        concept.links.map! { |link| OpenStruct.new(link) }
      end
    end

    private
    def url_for(endpoint, query_parts = {})
      base = [
        Exercism.config.git_server_url,
        "concepts",
        track_slug,
        concept_slug,
        endpoint
      ].join("/")

      query = {
        "git_sha": git_sha
      }.merge(query_parts).
        map { |k, v| "#{k}=#{v}" }.
        join("&")

      [base, query].join("?")
    end
  end
end
