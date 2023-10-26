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

    # We match criteria via wildcards to allow for partial matching
    criteria.each do |value|
      parts << { wildcard: { code: { value: "*#{value}*" } } }
    end

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

  def to_terms(value)
    return value.split if value.is_a?(String)

    [value].flatten
  end

  TIMEOUT = '400ms'.freeze
  private_constant :TIMEOUT

  class Fallback
    include Mandate

    initialize_with :exercise, :page, :per, :order, :criteria, :tags

    def call
      @solutions = Solution.joins(:published_exercise_representation).where(exercise:)

      sort!
      filter!
      paginate!

      @solutions
    end

    private
    attr_reader :solutions

    def filter!
      # By grouping, we force MySQL to return just one result per group
      @solutions = @solutions.group(:published_exercise_representation_id)

      # We can't filter on criteria as code is not stored in the database

      @solutions = @solutions.joins(:tags).where(tags: { tag: tags }) if tags.present?
    end

    def sort!
      case order
      when :newest
        @solutions = @solutions.order(id: :desc)
      when :oldest
        @solutions = @solutions.order(id: :asc)
      when :fewest_loc
        @solutions = @solutions.order(num_loc: :desc)
      when :highest_reputation
        # This is not track-specific reputation, but it's fine for the fallback
        @solutions = @solutions.joins(:user).order(reputation: :desc)
      else # :most_popular
        @solutions = @solutions.order(num_published_solutions: :desc, id: :asc)
      end
    end

    def paginate!
      @solutions = @solutions.
        page(page).
        per(per)
    end
  end
end
