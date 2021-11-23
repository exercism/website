class Document
  class SearchDocs
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
      results = Exercism.opensearch_client.search(index: Document::OPENSEARCH_INDEX, body: search_body)

      doc_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
      docs = doc_ids.present? ?
        Document.where(id: doc_ids).
          includes(:track).
          order(Arel.sql("FIND_IN_SET(id, '#{doc_ids.join(',')}')")).
          to_a : []

      total_count = results["hits"]["total"]["value"].to_i
      Kaminari.paginate_array(docs, total_count: total_count).
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
        sort: search_sort,

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
            track_slug.blank? ? nil : {
              terms: {
                'track.slug': [track_slug].flatten
              }
            },
            criteria.blank? ? nil : {
              multi_match: {
                query: criteria,
                fields: ['title^5', 'blurb^3', 'markdown']
              }
            }
          ].compact
        }
      }
    end

    def search_sort
      sort = [{ updated_at: { order: :desc, unmapped_type: "date" } }]
      sort.prepend(:_score) if criteria.present?
      sort
    end

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

        @solutions = @solutions.joins(exercise: :track)
        criteria.strip.split(" ").each do |crit|
          @solutions = @solutions.where(
            "exercises.title LIKE ? OR tracks.title LIKE ?",
            "%#{crit}%",
            "%#{crit}%"
          )
        end
      end

      def filter_track!
        return if track_slug.blank?

        @solutions = @solutions.joins(exercise: :track).
          where('tracks.slug': track_slug)
      end

      def filter_status!
        return if status.blank?

        @solutions = @solutions.where(status: status)
      end

      def filter_mentoring_status!
        return if mentoring_status.blank?

        @solutions = @solutions.where(mentoring_status: mentoring_status)
      end

      def sort!
        case order&.to_sym
        when :oldest_first
          @solutions = @solutions.order(id: :asc)
        else # :newest_first
          @solutions = @solutions.order(id: :desc)
        end
      end
    end
  end
end
