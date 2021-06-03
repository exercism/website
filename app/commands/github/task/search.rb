module Github
  class Task::Search
    include Mandate

    # Use class method rather than constant for
    # easier stubbing during testing
    def self.requests_per_page
      20
    end

    def initialize(actions: nil, knowledge: nil, areas: nil, sizes: nil, types: nil, repo_url: nil,
                   track_id: nil, order: nil, page: 1)
      @actions = actions
      @knowledge = knowledge
      @areas = areas
      @sizes = sizes
      @types = types
      @repo = repo_url
      @track_id = track_id
      @order = order
      @page = page
    end

    def call
      @tasks = Github::Task

      filter!
      sort!
      paginate!

      @tasks
    end

    private
    attr_reader :track_id, :actions, :knowledge, :areas, :sizes, :types, :repo, :order, :page, :tasks

    def filter!
      %i[track_id repo actions knowledge areas sizes types].each do |filter|
        value = send(filter)
        @tasks = @tasks.where(filter.to_s.singularize.to_sym => value) if value.present?
      end
    end

    def sort!
      case order
      when :track
        @tasks = @tasks.includes(:track).order('tracks.slug ASC')
      when :oldest
        @tasks = @tasks.order(opened_at: :asc)
      else
        @tasks = @tasks.order(opened_at: :desc)
      end
    end

    def paginate!
      @tasks = @tasks.page(page).per(self.class.requests_per_page)
    end
  end
end
