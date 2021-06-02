module Github
  class Issue::Search
    include Mandate

    # Use class method rather than constant for
    # easier stubbing during testing
    def self.requests_per_page
      20
    end

    def initialize(action: nil, knowledge: nil, module_: nil, size: nil, type: nil, repo_url: nil, order: nil, page: 1)
      @action = action
      @knowledge = knowledge
      @module_ = module_
      @size = size
      @type = type
      @repo_url = repo_url
      @order = order
      @page = page
    end

    def call
      @issues = Github::Issue

      filter_repo!
      filter_unclaimed!
      filter_action!
      filter_knowledge!
      filter_module!
      filter_size!
      filter_type!

      sort!
      paginate!
    end

    private
    attr_reader :action, :knowledge, :module_, :size, :type, :repo_url, :order, :page, :issues

    def filter_repo!
      return if repo_url.blank?

      @issues = @issues.where(repo: repo_url)
    end

    def filter_unclaimed!
      @issues = @issues.without_label('x:status/claimed')
    end

    %w[action knowledge module_ size type].each do |label|
      normalized_label = label.delete('_')

      define_method "filter_#{normalized_label}!" do
        return if send(label).blank?

        @issues = @issues.with_label(Github::IssueLabel.for_type(normalized_label.to_sym, send(label)))
      end
    end

    def sort!
      case order
      when :oldest
        @issues = @issues.order(opened_at: :asc)
      when :track
        @issues = @issues.order(repo: :asc)
      else
        @issues = @issues.order(opened_at: :desc)
      end
    end

    def paginate!
      @issues = @issues.page(page).per(self.class.requests_per_page)
    end
  end
end
