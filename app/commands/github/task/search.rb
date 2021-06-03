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
      @repo_url = repo_url
      @track_id = track_id
      @order = order
      @page = page
    end

    def call
      @tasks = Github::Task

      filter_track!
      filter_repo!
      filter_actions!
      filter_knowledge!
      filter_areas!
      filter_sizes!
      filter_types!

      sort!
      paginate!
    end

    private
    attr_reader :track_id, :actions, :knowledge, :areas, :sizes, :types, :repo_url, :order, :page, :tasks

    def filter_track!
      @tasks = @tasks.where(track_id: track_id) if track_id.present?
    end

    def filter_repo!
      @tasks = @tasks.where(repo: repo_url) if repo_url.present?
    end

    def filter_actions!
      @tasks = @tasks.where(action: actions) if actions.present?
    end

    def filter_knowledge!
      @tasks = @tasks.where(knowledge: knowledge) if knowledge.present?
    end

    def filter_areas!
      @tasks = @tasks.where(area: areas) if areas.present?
    end

    def filter_sizes!
      @tasks = @tasks.where(size: sizes) if sizes.present?
    end

    def filter_types!
      @tasks = @tasks.where(type: types) if types.present?
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
