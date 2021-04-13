class User::Notification
  class Retrieve
    include Mandate

    def initialize(user,
                   page: 1,
                   per_page: 5,
                   sorted: true, paginated: true)
      @user = user
      @page = page
      @per_page = per_page

      @sorted = sorted
      @paginated = paginated
    end

    def call
      setup!
      sort! if sorted?
      paginate! if paginated?

      @notifications
    end

    private
    attr_reader :user, :page, :per_page, :criteria, :order,
      :track_slug, :exercise_slugs

    %i[sorted paginated].each do |attr|
      define_method("#{attr}?") { instance_variable_get("@#{attr}") }
    end

    def setup!
      @notifications = user.notifications.not_pending
    end

    def sort!
      @notifications = @notifications.order(status: :asc, id: :desc)
    end

    def paginate!
      @notifications = @notifications.page(page).per(per_page)
    end
  end
end
