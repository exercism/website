class Solution
  class SearchUserSolutions
    include Mandate

    DEFAULT_PAGE = 1
    DEFAULT_PER = 25

    def self.default_per
      DEFAULT_PER
    end

    def initialize(user, criteria: nil, track_slug: nil, status: nil, mentoring_status: nil, page: nil, per: nil, order: nil)
      @user = user
      @criteria = criteria
      @track_slug = track_slug
      @status = status
      @mentoring_status = mentoring_status
      @page = page.present? && page.to_i.positive? ? page.to_i : DEFAULT_PAGE
      @per = per.present? && per.to_i.positive? ? per.to_i : self.class.default_per
      @order = order
    end

    def call
      @solutions = user.solutions
      filter_criteria!
      filter_track!
      filter_status!
      filter_mentoring_status!
      sort!

      @solutions.page(page).per(per)
    end

    private
    attr_reader :user, :criteria, :track_slug, :status, :mentoring_status,
      :per, :page, :order,
      :solutions

    def filter_criteria!
      return if criteria.blank?

      @solutions = @solutions.joins(exercise: :track)
      criteria.strip.split(" ").each do |crit|
        @solutions = @solutions.where(
          "exercises.title LIKE ? OR tracks.title LIKE ?",
          "#{crit}%",
          "#{crit}%"
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
