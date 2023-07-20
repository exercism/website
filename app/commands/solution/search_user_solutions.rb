class Solution::SearchUserSolutions
  include Mandate

  DEFAULT_PAGE = 1
  DEFAULT_PER = 24

  def self.default_per
    DEFAULT_PER
  end

  def initialize(user, page: nil, per: nil, order: nil,
                 criteria: nil, track_slug: nil, status: nil, mentoring_status: nil,
                 sync_status: nil, tests_status: nil, head_tests_status: nil)
    @user = user
    @criteria = criteria
    @track_slug = track_slug
    @status = status
    @mentoring_status = mentoring_status
    @sync_status = sync_status&.to_sym
    @tests_status = tests_status
    @head_tests_status = head_tests_status
    @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
    @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
    @order = order&.to_sym
  end

  def call
    results = Exercism.opensearch_client.search(
      index: Solution::OPENSEARCH_INDEX,
      body: search_body,
      timeout: TIMEOUT,
      allow_partial_search_results: false
    )

    solution_ids = results["hits"]["hits"].map { |hit| hit["_source"]["id"] }
    solutions = solution_ids.present? ?
      Solution.where(id: solution_ids).sort_by { |s| solution_ids.index(s.id) }
        : []

    total_count = results["hits"]["total"]["value"].to_i
    Kaminari.paginate_array(solutions, total_count:).
      page(page).per(per)
  rescue StandardError => e
    Bugsnag.notify(e)
    Fallback.(user, page, per, track_slug, status, mentoring_status,
      criteria, order, sync_status, tests_status, head_tests_status)
  end

  private
  attr_reader :user, :criteria, :track_slug, :status, :mentoring_status, :sync_status, :tests_status, :head_tests_status,
    :per, :page, :order,
    :solutions

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
          { term: { 'user.id': user.id } },
          track_slug.blank? ? nil : { terms: { 'track.slug.keyword': [track_slug].flatten } },
          status.blank? ? nil : { terms: { 'status.keyword': [status].flatten } },
          mentoring_status.blank? ? nil : { terms: { 'mentoring_status.keyword': [mentoring_status].flatten } },
          sync_status.nil? ? nil : { term: { 'out_of_date': sync_status == :out_of_date } },
          tests_status.blank? ? nil : { terms: { 'published_iteration.tests_status.keyword': to_terms(tests_status) } },
          head_tests_status.blank? ? nil : { terms: { 'published_iteration.head_tests_status.keyword': to_terms(head_tests_status) } },
          criteria.blank? ? nil : {
            query_string: {
              query: criteria.split(' ').map { |c| "*#{c}*" }.join(' AND '),
              fields: ['exercise.title', 'track.title']
            }
          }
        ].compact
      }
    }
  end

  def search_sort
    case order
    when :newest_first
      [{ id: { order: :desc, unmapped_type: "integer" } }]
    when :oldest_first
      [{ id: { order: :asc, unmapped_type: "integer" } }]
    else # :most_starred
      [{ num_stars: { order: :desc, unmapped_type: "integer" } }]
    end
  end

  def to_terms(value)
    return value.split if value.is_a?(String)

    [value].flatten
  end

  TIMEOUT = '100ms'.freeze
  private_constant :TIMEOUT

  class Fallback
    include Mandate

    initialize_with :user, :page, :per, :track_slug, :status, :mentoring_status, :criteria, :order,
      :sync_status, :tests_status, :head_tests_status

    def call
      @solutions = user.solutions
      filter_criteria!
      filter_track!
      filter_status!
      filter_mentoring_status!
      filter_sync_status!
      filter_tests_status!
      filter_head_tests_status!
      sort!

      @solutions.page(page).per(per)
    end

    private
    attr_reader :solutions

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

      @solutions = @solutions.where(status:)
    end

    def filter_mentoring_status!
      return if mentoring_status.blank?

      @solutions = @solutions.where(mentoring_status:)
    end

    def filter_tests_status!
      return if tests_status.blank?

      @solutions = @solutions.joins(published_iteration: :submission).where('submissions.tests_status': tests_status)
    end

    def filter_head_tests_status!
      return if head_tests_status.blank?

      @solutions = @solutions.where(published_iteration_head_tests_status: head_tests_status)
    end

    def filter_sync_status!
      case sync_status
      when :up_to_date
        @solutions = @solutions.joins(published_iteration: :exercise).
          where('solutions.git_important_files_hash = exercises.git_important_files_hash')
      when :out_of_date
        @solutions = @solutions.joins(published_iteration: :exercise).
          where.not('solutions.git_important_files_hash = exercises.git_important_files_hash')
      end
    end

    def sort!
      case order
      when :newest_first
        @solutions = @solutions.order(id: :desc)
      when :oldest_first
        @solutions = @solutions.order(id: :asc)
      else # :most_starred
        @solutions = @solutions.order(num_stars: :desc)
      end
    end
  end
end
