class Solution::SearchViaRepresentations
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 24
  MAX_ROWS = 10_000

  def self.default_per
    DEFAULT_PER
  end

  def initialize(exercise, page: nil, per: nil, order: nil, criteria: nil, tags: nil)
    @exercise = exercise
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
    @order = order&.to_sym || :most_popular
    @criteria = criteria&.split.to_a
    @tags = tags.present? && tags.is_a?(String) ? tags.split : tags.to_a
  end

  def call
    # ES can only handle paginating up to 10_000 rows.
    # If it's above that, return nothing
    return Kaminari.paginate_array([], total_count: MAX_ROWS).page(page).per(per) if from + per > MAX_ROWS

    results = Exercism.opensearch_client.search(
      index: Exercise::Representation::OPENSEARCH_INDEX,
      body: search_body,
      timeout: TIMEOUT,
      allow_partial_search_results: false
    )

    solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["#{featured_solution_type}_solution_id"] }
    solutions = solution_ids.present? ?
      Solution.where(id: solution_ids).sort_by { |s| solution_ids.index(s.id) } :
      []

    total_count = [results["hits"]["total"]["value"].to_i, MAX_ROWS].min

    Kaminari.paginate_array(solutions, total_count:).
      page(page).per(per)
  rescue StandardError => e
    Bugsnag.notify(e)
    Fallback.(exercise, page, per, order, criteria, tags)
  end

  private
  attr_reader :exercise, :per, :page, :order, :solutions, :criteria, :tags

  def search_body
    {
      query: search_query,
      sort: search_sort,

      # Only return the solution IDs, not the entire document, to improve performance
      _source: ["#{featured_solution_type}_solution_id"],

      # Paging information
      from:,
      size: per
    }
  end

  def featured_solution_type = order == :highest_reputation ? :prestigious : :oldest

  memoize
  def from
    (page - 1) * per
  end

  def search_query
    parts = [
      { term: { 'exercise.id': exercise.id } }
    ]

    parts << criteria_query if criteria_query.present?

    # Tags are matched exactly
    tags.each do |tag|
      parts << { terms: { "tags.keyword": [tag] } }
    end

    { bool: { must: parts } }
  end

  def search_sort
    case order
    when :newest
      [{ oldest_solution_id: { order: :desc, unmapped_type: "integer" } }]
    when :oldest
      [{ oldest_solution_id: { order: :asc, unmapped_type: "integer" } }]
    when :fewest_loc
      [{ num_loc: { order: :asc, unmapped_type: "integer" } }]
    when :highest_reputation
      [{ max_reputation: { order: :desc, unmapped_type: "integer" } }]
    else # :most_popular
      [{ num_solutions: { order: :desc, unmapped_type: "integer" } }]
    end
  end

  memoize
  def criteria_query
    return if criteria_query_terms.empty?

    {
      simple_query_string: {
        query: criteria_query_terms.join(' + '),
        fields: ["code"],
        analyze_wildcard: true
      }
    }
  end

  memoize
  def criteria_query_terms
    criteria.filter_map do |value|
      next if value.size < MIN_CRITERIA_LEN

      term = Infrastructure::EscapeOpensearchSimpleQueryStringTerm.(value)
      "#{term}~#{CODE_TERM_FUZZINESS}"
    end
  end

  TIMEOUT = '400ms'.freeze
  MIN_CRITERIA_LEN = 3
  CODE_TERM_FUZZINESS = 1
  private_constant :TIMEOUT, :MIN_CRITERIA_LEN, :CODE_TERM_FUZZINESS

  class Fallback
    include Mandate

    initialize_with :exercise, :page, :per, :order, :criteria, :tags

    def call
      @representations = exercise.representations.where('num_published_solutions > 0')

      sort!
      filter!
      paginate!

      @representations = @representations.includes(:prestigious_solution).page(page).per(per)

      Kaminari.paginate_array(@representations.map(&:prestigious_solution).compact, total_count: @representations.total_count).
        page(page).per(per)
    end

    private
    attr_reader :solutions

    def filter!
      # We can't filter on criteria as code is not stored in the database
      @representations = @representations.joins(prestigious_solution: :tags).where(tags: { tag: tags }) if tags.present?
    end

    def sort!
      case order
      when :newest
        @representations = @representations.joins(:prestigious_solution).order('solutions.id': :desc)
      when :oldest
        @representations = @representations.joins(:prestigious_solution).order('solutions.id': :asc)
      when :fewest_loc
        @representations = @representations.joins(:prestigious_solution).order('solutions.num_loc': :asc)
      when :highest_reputation
        # This is not track-specific reputation, but it's fine for the fallback
        @representations = @representations.joins(prestigious_solution: :user).order('users.reputation': :desc)
      else # :most_popular
        @representations = @representations.order(num_published_solutions: :desc, id: :asc)
      end
    end

    def paginate!
      @representations = @representations.
        page(page).
        per(per)
    end
  end
end
