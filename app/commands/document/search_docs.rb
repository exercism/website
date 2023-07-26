class Document::SearchDocs
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 25

  def self.default_per
    DEFAULT_PER
  end

  def initialize(criteria: nil, track_slug: nil, page: nil, per: nil)
    @criteria = criteria
    @track_slug = track_slug
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
  end

  def call
    results = Exercism.opensearch_client.search(
      index: Document::OPENSEARCH_INDEX,
      body: search_body,
      timeout: TIMEOUT,
      allow_partial_search_results: false
    )

    doc_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
    docs = doc_ids.present? ?
      Document.where(id: doc_ids).includes(:track).sort_by { |d| doc_ids.index(d.id) } :
          []

    total_count = results["hits"]["total"]["value"].to_i
    Kaminari.paginate_array(docs, total_count:).
      page(page).per(per)
  rescue StandardError => e
    Bugsnag.notify(e)
    Fallback.(criteria, track_slug, page, per)
  end

  private
  attr_reader :criteria, :track_slug, :page, :per, :docs

  def search_body
    {
      query: search_query,
      sort: :_score,

      # Only return the solution IDs, not the entire document, to improve performance
      _source: [:id],

      # Paging information
      from: (page - 1) * per,
      size: per
    }
  end

  def search_query
    {
      bool: {
        must: [
          track_slug.blank? ? nil : { terms: { 'track.slug.keyword': [track_slug].flatten } },
          criteria.blank? ? nil : {
            query_string: {
              query: criteria.split(' ').map { |c| "*#{c}*" }.join(' AND '),
              fields: ['title^5', 'blurb^3', 'markdown']
            }
          }
        ].compact
      }
    }
  end

  TIMEOUT = '100ms'.freeze
  private_constant :TIMEOUT

  class Fallback
    include Mandate

    initialize_with :criteria, :track_slug, :page, :per

    def call
      @docs = Document
      filter_criteria!
      filter_track!
      sort!

      @docs.page(page).per(per)
    end

    private
    attr_reader :docs

    def filter_criteria!
      return if criteria.blank?

      criteria.strip.split(" ").each do |crit|
        @docs = @docs.where("title LIKE ? OR blurb LIKE ?", "%#{crit}%", "%#{crit}%")
      end
    end

    def filter_track!
      return if track_slug.blank?

      @docs = @docs.joins(:track).where('tracks.slug': track_slug)
    end

    def sort!
      @docs = @docs.order(id: :asc)
    end
  end
end
